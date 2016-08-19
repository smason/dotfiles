function iplant-cred --description "Load iPlant credentials from OSX keychain and set as environment variables"
  set -gx IPLANT_USERNAME (security find-generic-password -s iPlant | sed -nEe 's/ +"acct"<blob>="(.+)"$/\1/p')
  set -gx IPLANT_PASSWORD (security find-generic-password -s iPlant -gw)
end
