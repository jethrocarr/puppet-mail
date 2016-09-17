# Fetch the IP addresses for the provided DNS name and make sure they all
# belong to this server.

require 'resolv'

module Puppet::Parser::Functions
    newfunction(:mailcheckdnsforwards, :type => :rvalue) do |args|
        result = false

        # DNS lookup
        addresses_lookup = []
        addresses_lookup = Resolv.new.getaddresses(args[0][0])

        # We set to true if we get at least one value returned but retract if
        # any of the IPs are not correct.
        if addresses_lookup.count >= 1
          result = true
        end

        # Make sure all the addresses that were returned are actually
        # associated with this server.
        addresses_lookup.each { |address|
            # Use function from stdlib
            unless function_has_interface_with("ipaddress", address)
              result = false
            end
        }

        return result
    end
end

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
