Facter.add("hiera_ready") do
  setcode do
    hiera_configured = false
      
    begin 
      require 'hiera_puppet'
      
      config = HieraPuppet.hiera_config()
      
      if config.is_a?(Hash)
        hiera_configured = true
      end
      
    rescue Exception # Prevent abortions.
    end
  
    if hiera_configured
      true
    else
      nil
    end
  end
end