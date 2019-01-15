class CustomizationTemplateIgnition < CustomizationTemplate
  DEFAULT_FILENAME = "ignition.json".freeze

  def ignition_path(pxe_server, pxe_image, mac, suffix)
    File.join(pxe_server.customization_directory,
              "#{pxe_image.class.pxe_server_filename(mac)}.#{suffix}.json")
  end

  def boot_ignition_path(pxe_server, pxe_image, mac)
    ignition_path(pxe_server, pxe_image, mac, "boot")
  end

  def boot_ignition_url(pxe_server, pxe_image, mac)
    File.join(pxe_server.access_url,
              boot_ignition_path(pxe_server, pxe_image, mac))
  end

  def install_ignition_path(pxe_server, pxe_image, mac)
    ignition_path(pxe_server, pxe_image, mac, "install")
  end

  def install_ignition_url(pxe_server, pxe_image, mac)
    File.join(pxe_server.access_url,
              install_ignition_path(pxe_server, pxe_image, mac))
  end

  def kernel_args(pxe_server, pxe_image, mac)
    {
      "coreos.config.url" => boot_ignition_url(pxe_server, pxe_image, mac),
      "coreos.first_boot" => "1",
      "coreos.autologin"  => "tty1",
    }
  end

  def default_filename
    DEFAULT_FILENAME
  end

  def create_files_on_server(pxe_server, pxe_image, mac, _win_image, substitution_options)
    require "erb"

    installer_source = <<~INSTALLER
      #!/bin/bash -ex
      curl --retry 10 "#{install_ignition_url(pxe_server, pxe_image, mac)}" -o ignition.json
      coreos-install -d /dev/sda -i ignition.json
      udevadm settle
      systemctl reboot
    INSTALLER
    unit_source = <<~UNIT
      [Unit]
      Requires=network-online.target
      After=network-online.target
      [Service]
      Type=simple
      ExecStart=/opt/installer
      [Install]
      WantedBy=multi-user.target
    UNIT

    pxe_server.write_file(
      boot_ignition_path(pxe_server, pxe_image, mac),
      {
        "ignition" => {
          "version" => "2.2.0"
        },
        "storage"  => {
          "files" => [
            {
              "filesystem" => "root",
              "path"       => "/opt/installer",
              "contents"   => {
                "source" => "data:,#{ERB::Util.url_encode(installer_source)}",
              },
              "mode"       => 320
            }
          ]
        },
        "systemd" => {
          "units" => [
            {
              "contents" => unit_source,
              "enable"   => true,
              "name"     => "installer.service"
            }
          ]
        }
      }.to_json
    )

    pxe_server.write_file(
      install_ignition_path(pxe_server, pxe_image, mac),
      script_with_substitution(substitution_options)
    )
  end

  def delete_files_on_server(pxe_server, pxe_image, mac, _windows_image)
    pxe_server.delete_file(boot_ignition_path(pxe_server, pxe_image, mac))
    pxe_server.delete_file(install_ignition_path(pxe_server, pxe_image, mac))
  end
end
