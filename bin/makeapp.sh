#!/bin/bash

# misc config
chromePath="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

echo -n "What should the Application be called (e.g. Google Calendar)? "
read name

appPath="/Applications/$name.app"
if [ -d "$appPath" ]; then
    echo "Error: '$appPath' already exists.  Please uninstall or delete it first."
    exit 1
fi

echo -n "What is the url (e.g. https://www.google.com/calendar/render)? "
read url

while true; do
    echo -n "What is the path to the icon (e.g. ~/Desktop/icon.png)? "
    read icon
    [ -f "$icon" ] && break
    echo "Icon file doesn't exist, try again."
done

# various paths used when creating the app
resourcePath="$appPath/Contents/Resources"
execPath="$appPath/Contents/MacOS" 
plistPath="$appPath/Contents/Info.plist"
profilePathUneval="\$HOME/Library/WebApps/$name/Google Chrome Profile"
profilePath="`eval echo $profilePathUneval`"

# make the directories
mkdir -p  "$resourcePath" "$execPath" "$profilePath"

# convert the icon and copy into Resources
if [ -f "$icon" ] ; then
    sips -s format tiff "$icon" --out "$resourcePath/icon.tiff" --resampleHeightWidthMax 512
    tiff2icns -noLarge "$resourcePath/icon.tiff"
fi

# create the executable
cat >"$execPath/$name" <<EOF
#!/bin/sh
exec "$chromePath" --force-app-mode --app="$url" --user-data-dir="$profilePathUneval" "\$@"
EOF
chmod +x "$execPath/$name"

# create the Info.plist 
cat > "$plistPath" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" “http://www.apple.com/DTDs/PropertyList-1.0.dtd”>
<plist version=”1.0″>
<dict>
<key>CFBundleExecutable</key>
<string>$name</string>
<key>CFBundleIconFile</key>
<string>icon</string>
</dict>
</plist>
EOF
