# Fetch the IP addresses for the provided DNS name and make sure they all
# belong to this server.

require 'resolv'

module Puppet::Parser::Functions
    newfunction(:mailcheckdnsforwards, :type => :rvalue) do |args|
        result = false

        # DNS lookup
        addresses_lookup = []
        addresses_lookup = Resolv::DNS.new.getaddresses(args[0])

        # We set to true if we get at least one value returned but retract if
        # any of the IPs are not correct.
        if addresses_lookup.count >= 1
          result = true
        end

        # Make sure all the addresses that were returned are actually
        # associated with this server.
        addresses_lookup.each { |address|
            # Use function from stdlib
            if address.is_a?(Resolv::IPv4)
                unless function_has_interface_with(["ipaddress", address.to_s])
                    result = false
                end
            elsif address.is_a?(Resolv::IPv6)
                unless function_has_interface_with(["ipaddress6", address.to_s.downcase])
                    result = false
                end
            end  
        }

        return result
    end
end

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
