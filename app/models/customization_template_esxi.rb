class CustomizationTemplateEsxi < CustomizationTemplate
  DEFAULT_FILENAME = "ks.cfg".freeze

  def kickstart_path(pxe_server, pxe_image, mac)
    File.join(pxe_server.customization_directory,
              "#{pxe_image.class.pxe_server_filename(mac)}.ks.cfg")
  end

  def kickstart_url(pxe_server, pxe_image, mac)
    File.join(pxe_server.access_url,
              kickstart_path(pxe_server, pxe_image, mac))
  end

  def kernel_args(pxe_server, pxe_image, mac)
    {
      "ks" => kickstart_url(pxe_server, pxe_image, mac),
    }
  end

  def default_filename
    DEFAULT_FILENAME
  end

  def create_files_on_server(pxe_server, pxe_image, mac, _win_image, substitution_options)
    pxe_server.write_file(
      kickstart_path(pxe_server, pxe_image, mac),
      script_with_substitution(substitution_options),
    )
  end

  def delete_files_on_server(pxe_server, pxe_image, mac_address, _windows_image)
    pxe_server.delete_file(kickstart_path(pxe_server, pxe_image, mac))
  end
end
