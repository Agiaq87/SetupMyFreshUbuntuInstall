#!/bin/bash

show_multimedia_menu() {
    log INFO "Opening multimedia menu..."
    # Define available software (format: id|name|description)
    local multimedia_items=(
        "vlc|VLC Media Player|Popular multimedia player supporting most formats"
        "mpv|MPV|Minimalist command-line media player"
        "celluloid|Celluloid|Modern GTK frontend for MPV"
        "kodi|Kodi|Media center for managing and playing multimedia content"
        "plex|Plex Media Server|Stream your media collection to any device"
        "jellyfin|Jellyfin|Free and open source media server alternative to Plex"
        "spotify|Spotify|Music streaming service"
        "audacity|Audacity|Audio editor and recorder"
        "ocenaudio|Ocenaudio|Easy-to-use audio editor"
        "ardour|Ardour|Professional digital audio workstation"
        "lmms|LMMS|Music production software"
        "reaper|REAPER|Digital audio workstation"
        "kdenlive|Kdenlive|Professional video editor"
        "openshot|OpenShot|Easy-to-use video editor"
        "shotcut|Shotcut|Cross-platform video editor"
        "davinci-resolve|DaVinci Resolve|Professional video editing and color grading"
        "olive-editor|Olive|Professional open-source video editor"
        "pitivi|Pitivi|Simple video editor for GNOME"
        "flowblade|Flowblade|Multitrack non-linear video editor"
        "blender|Blender|3D creation suite with video editing"
        "obs-studio|OBS Studio|Video recording and live streaming"
        "simplescreenrecorder|SimpleScreenRecorder|Feature-rich screen recorder"
        "peek|Peek|Animated GIF screen recorder"
        "kazam|Kazam|Simple screen recording program"
        "handbrake|HandBrake|Video transcoder"
        "ffmpeg|FFmpeg|Complete multimedia framework for video/audio processing"
        "mkvtoolnix|MKVToolNix|Tools for creating and editing Matroska files"
        "mediainfo|MediaInfo|Display technical information about media files"
        "gimp|GIMP|GNU Image Manipulation Program"
        "krita|Krita|Professional painting program"
        "inkscape|Inkscape|Vector graphics editor"
        "darktable|Darktable|Photography workflow and RAW developer"
        "rawtherapee|RawTherapee|RAW image processing program"
        "digikam|digiKam|Professional photo management"
        "shotwell|Shotwell|Photo manager for GNOME"
        "rapid-photo-downloader|Rapid Photo Downloader|Import photos and videos from cameras"
        "upscayl|Upscayl|AI image upscaler"
        "youtube-dl|yt-dlp|Download videos from YouTube and other sites"
        "tartube|Tartube|GUI for youtube-dl/yt-dlp"
        "parabolic|Parabolic|Download web videos and audio"
        "clementine|Clementine|Music player and library organizer"
        "rhythmbox|Rhythmbox|Music player for GNOME"
        "strawberry|Strawberry|Music player and collection organizer"
        "elisa|Elisa|Simple music player by KDE"
        "museeks|Museeks|Minimalist music player"
        "soundconverter|Sound Converter|Audio file converter for GNOME"
        "easytag|EasyTAG|Audio file tag editor"
        "picard|MusicBrainz Picard|Music tagger"
        "puddletag|Puddletag|Audio tag editor"
        "brasero|Brasero|Disc burning application for GNOME"
        "k3b|K3B|Disc burning application for KDE"
        "makemkv|MakeMKV|Rip DVD and Blu-ray to MKV"
        "cheese|Cheese|Webcam application"
        "guvcview|GuvcView|Webcam viewer and capture"
        "vokoscreen|vokoscreen|Easy to use screencast creator"
        "green-recorder|Green Recorder|Simple screen recorder"
        "pinta|Pinta|Simple drawing and image editing"
        "mypaint|MyPaint|Fast and easy painting application"
        "natron|Natron|Open-source compositing software"
        "synfigstudio|Synfig Studio|2D animation software"
        "opentoonz|OpenToonz|2D animation production software"
        "pulseaudio|PulseAudio Tools|Advanced audio control utilities"
        "pavucontrol|PavuControl|PulseAudio Volume Control"
        "easyeffects|EasyEffects|Audio effects for PipeWire/PulseAudio"
        "carla|Carla|Audio plugin host"
        "qjackctl|QjackCtl|JACK audio server control"
        "hydrogen|Hydrogen|Drum machine and sequencer"
        "musescore|MuseScore|Music notation software"
        "tuxguitar|TuxGuitar|Multitrack guitar tablature editor"
    )

    # Show checklist
    local choices
    choices=$(show_checklist "Multimedia Tools Selection" "Choose multimedia tools to install:" "${multimedia_items[@]}")

    # Exit if cancelled
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        log INFO "Multimedia tools selection cancelled"
        return
    fi

    log INFO "Selected multimedia tools: $choices"
    IFS='|' read -ra choice_array <<< "$choices"

    # Process each choice
    for choice_raw in "${choice_array[@]}"; do
        local choice
        choice=$(echo "$choice_raw" | xargs)
        log DEBUG "Processing selection: $choice"

        case $choice in
            "vlc")
                install_package_secure "VLC Media Player" "vlc" "snap" "Multimedia player" || log WARN "VLC installation failed, continuing..."
                ;;

            "mpv")
                install_package_secure "MPV" "mpv" "nala" "Minimalist media player" || log WARN "MPV installation failed, continuing..."
                ;;

            "celluloid")
                install_package_secure "Celluloid" "celluloid" "nala" "GTK frontend for MPV" || log WARN "Celluloid installation failed, continuing..."
                ;;

            "kodi")
                install_package_secure "Kodi" "kodi" "snap" "Media center application" || log WARN "Kodi installation failed, continuing..."
                ;;

            "plex")
                log INFO "Installing Plex Media Server..."
                local plex_deb="/tmp/plex.deb"
                wget -O "$plex_deb" "https://downloads.plex.tv/plex-media-server-new/1.40.5.8897-e5c93e153/debian/plexmediaserver_1.40.5.8897-e5c93e153_amd64.deb" 2>&1 | \
                    zenity --progress --title="Downloading Plex" --text="Downloading..." --pulsate --auto-close

                if [ -f "$plex_deb" ]; then
                    install_package_secure "Plex Media Server" "$plex_deb" "nala" "Media server" || log WARN "Plex installation failed, continuing..."
                    rm -f "$plex_deb"
                    show_message "Info" "Plex is now installed!\n\nAccess it at: http://localhost:32400/web"
                else
                    log ERROR "Failed to download Plex"
                fi
                ;;

            "jellyfin")
                log INFO "Installing Jellyfin..."
                # Add Jellyfin repository
                curl -fsSL https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/jellyfin.gpg
                echo "deb [signed-by=/usr/share/keyrings/jellyfin.gpg arch=amd64] https://repo.jellyfin.org/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list

                install_package_secure "Jellyfin" "jellyfin" "nala" "Free media server" || log WARN "Jellyfin installation failed, continuing..."
                show_message "Info" "Jellyfin is now installed!\n\nAccess it at: http://localhost:8096"
                ;;

            "spotify")
                install_package_secure "Spotify" "spotify" "snap" "Music streaming service" || log WARN "Spotify installation failed, continuing..."
                ;;

            "audacity")
                install_package_secure "Audacity" "audacity" "nala" "Audio editor and recorder" || log WARN "Audacity installation failed, continuing..."
                ;;

            "ocenaudio")
                log INFO "Installing Ocenaudio..."
                local ocean_deb="/tmp/ocenaudio.deb"
                wget -O "$ocean_deb" "https://www.ocenaudio.com/downloads/index.php/ocenaudio_debian9_64.deb" 2>&1 | \
                    zenity --progress --title="Downloading Ocenaudio" --text="Downloading..." --pulsate --auto-close

                if [ -f "$ocean_deb" ]; then
                    install_package_secure "Ocenaudio" "$ocean_deb" "nala" "Audio editor" || log WARN "Ocenaudio installation failed, continuing..."
                    rm -f "$ocean_deb"
                else
                    log ERROR "Failed to download Ocenaudio"
                fi
                ;;

            "ardour")
                install_package_secure "Ardour" "ardour" "nala" "Digital audio workstation" || log WARN "Ardour installation failed, continuing..."
                ;;

            "lmms")
                install_package_secure "LMMS" "lmms" "nala" "Music production software" || log WARN "LMMS installation failed, continuing..."
                ;;

            "reaper")
                show_message "Manual Installation" "REAPER requires manual installation:\n\n1. Visit: https://www.reaper.fm/download.php\n2. Download Linux version\n3. Extract and run install-reaper.sh\n\nNote: Free to evaluate, license required for continued use."
                xdg-open "https://www.reaper.fm/download.php" 2>/dev/null &
                ;;

            "kdenlive")
                install_package_secure "Kdenlive" "kdenlive" "flatpak" "Professional video editor" || log WARN "Kdenlive installation failed, continuing..."
                ;;

            "openshot")
                install_package_secure "OpenShot" "openshot-qt" "nala" "Video editor" || log WARN "OpenShot installation failed, continuing..."
                ;;

            "shotcut")
                install_package_secure "Shotcut" "shotcut" "snap" "Video editor" || log WARN "Shotcut installation failed, continuing..."
                ;;

            "davinci-resolve")
                show_message "Manual Installation" "DaVinci Resolve requires manual installation:\n\n1. Visit: https://www.blackmagicdesign.com/products/davinciresolve\n2. Download Linux version\n3. Extract and run installer\n4. May require additional dependencies\n\nNote: Free version available, Studio version requires purchase."
                xdg-open "https://www.blackmagicdesign.com/products/davinciresolve" 2>/dev/null &
                ;;

            "olive-editor")
                install_package_secure "Olive Editor" "org.olivevideoeditor.Olive" "flatpak" "Professional video editor" || log WARN "Olive installation failed, continuing..."
                ;;

            "pitivi")
                install_package_secure "Pitivi" "pitivi" "flatpak" "Video editor for GNOME" || log WARN "Pitivi installation failed, continuing..."
                ;;

            "flowblade")
                install_package_secure "Flowblade" "flowblade" "nala" "Multitrack video editor" || log WARN "Flowblade installation failed, continuing..."
                ;;

            "blender")
                install_package_secure "Blender" "blender" "snap" "3D creation suite" || log WARN "Blender installation failed, continuing..."
                ;;

            "obs-studio")
                add_repository "OBS Studio" \
                    "https://ppa.launchpadcontent.net/obsproject/obs-studio/ubuntu" \
                    "deb http://ppa.launchpad.net/obsproject/obs-studio/ubuntu $(lsb_release -cs) main" \
                    "/etc/apt/sources.list.d/obs-studio.list"
                install_package_secure "OBS Studio" "obs-studio" "nala" "Streaming and recording" || log WARN "OBS Studio installation failed, continuing..."
                ;;

            "simplescreenrecorder")
                install_package_secure "SimpleScreenRecorder" "simplescreenrecorder" "nala" "Screen recorder" || log WARN "SimpleScreenRecorder installation failed, continuing..."
                ;;

            "peek")
                install_package_secure "Peek" "peek" "nala" "GIF screen recorder" || log WARN "Peek installation failed, continuing..."
                ;;

            "kazam")
                install_package_secure "Kazam" "kazam" "nala" "Screen recording tool" || log WARN "Kazam installation failed, continuing..."
                ;;

            "handbrake")
                install_package_secure "HandBrake" "fr.handbrake.ghb" "flatpak" "Video transcoder" || log WARN "HandBake installation failed, continuing..."
                ;;

            "ffmpeg")
                install_package_secure "FFmpeg" "ffmpeg" "nala" "Multimedia framework" || log WARN "FFmpeg installation failed, continuing..."
                ;;

            "mkvtoolnix")
                install_package_secure "MKVToolNix" "mkvtoolnix mkvtoolnix-gui" "nala" "Matroska tools" || log WARN "MKVToolNix installation failed, continuing..."
                ;;

            "mediainfo")
                install_package_secure "MediaInfo" "mediainfo mediainfo-gui" "nala" "Media file information" || log WARN "MediaInfo installation failed, continuing..."
                ;;

            "gimp")
                install_package_secure "GIMP" "gimp" "nala" "Image manipulation program" || log WARN "GIMP installation failed, continuing..."
                ;;

            "krita")
                install_package_secure "Krita" "krita" "snap" "Digital painting application" || log WARN "Krita installation failed, continuing..."
                ;;

            "inkscape")
                install_package_secure "Inkscape" "inkscape" "nala" "Vector graphics editor" || log WARN "Inkscape installation failed, continuing..."
                ;;

            "darktable")
                install_package_secure "Darktable" "darktable" "nala" "Photography workflow" || log WARN "Darktable installation failed, continuing..."
                ;;

            "rawtherapee")
                install_package_secure "RawTherapee" "rawtherapee" "nala" "RAW image processing" || log WARN "RawTherapee installation failed, continuing..."
                ;;

            "digikam")
                install_package_secure "digiKam" "digikam" "nala" "Photo management" || log WARN "digiKam installation failed, continuing..."
                ;;

            "shotwell")
                install_package_secure "Shotwell" "shotwell" "nala" "Photo manager for GNOME" || log WARN "Shotwell installation failed, continuing..."
                ;;

            "rapid-photo-downloader")
                install_package_secure "Rapid Photo Downloader" "rapid-photo-downloader" "nala" "Import photos from cameras" || log WARN "Rapid Photo Downloader installation failed, continuing..."
                ;;

            "upscayl")
                log INFO "Installing Upscayl..."
                local upscayl_url=$(curl -s https://api.github.com/repos/upscayl/upscayl/releases/latest | grep "browser_download_url.*Linux.deb" | cut -d '"' -f 4)
                local upscayl_deb="/tmp/upscayl.deb"

                wget -O "$upscayl_deb" "$upscayl_url" 2>&1 | \
                    zenity --progress --title="Downloading Upscayl" --text="Downloading..." --pulsate --auto-close

                if [ -f "$upscayl_deb" ]; then
                    install_package_secure "Upscayl" "$upscayl_deb" "nala" "AI image upscaler" || log WARN "Upscayl installation failed, continuing..."
                    rm -f "$upscayl_deb"
                else
                    log ERROR "Failed to download Upscayl"
                fi
                ;;

            "youtube-dl")
                install_package_secure "yt-dlp" "yt-dlp" "nala" "Video downloader" || log WARN "yt-dlp installation failed, continuing..."
                ;;

            "tartube")
                install_package_secure "Tartube" "tartube" "flatpak" "GUI for yt-dlp" || log WARN "Tartube installation failed, continuing..."
                ;;

            "parabolic")
                install_package_secure "Parabolic" "org.nickvision.tubeconverter" "flatpak" "Download web videos" || log WARN "Parabolic installation failed, continuing..."
                ;;

            "clementine")
                install_package_secure "Clementine" "clementine" "nala" "Music player" || log WARN "Clementine installation failed, continuing..."
                ;;

            "rhythmbox")
                install_package_secure "Rhythmbox" "rhythmbox" "nala" "Music player for GNOME" || log WARN "Rhythmbox installation failed, continuing..."
                ;;

            "strawberry")
                install_package_secure "Strawberry" "strawberry" "nala" "Music player" || log WARN "Strawberry installation failed, continuing..."
                ;;

            "elisa")
                install_package_secure "Elisa" "elisa" "nala" "Music player by KDE" || log WARN "Elisa installation failed, continuing..."
                ;;

            "museeks")
                log INFO "Installing Museeks..."
                local museeks_url=$(curl -s https://api.github.com/repos/martpie/museeks/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)
                local museeks_deb="/tmp/museeks.deb"

                wget -O "$museeks_deb" "$museeks_url" 2>&1 | \
                    zenity --progress --title="Downloading Museeks" --text="Downloading..." --pulsate --auto-close

                if [ -f "$museeks_deb" ]; then
                    install_package_secure "Museeks" "$museeks_deb" "nala" "Minimalist music player" || log WARN "Museeks installation failed, continuing..."
                    rm -f "$museeks_deb"
                else
                    log ERROR "Failed to download Museeks"
                fi
                ;;

            "soundconverter")
                install_package_secure "Sound Converter" "soundconverter" "nala" "Audio file converter" || log WARN "Sound Converter installation failed, continuing..."
                ;;

            "easytag")
                install_package_secure "EasyTAG" "easytag" "nala" "Audio tag editor" || log WARN "EasyTAG installation failed, continuing..."
                ;;

            "picard")
                install_package_secure "MusicBrainz Picard" "picard" "nala" "Music tagger" || log WARN "Picard installation failed, continuing..."
                ;;

            "puddletag")
                install_package_secure "Puddletag" "puddletag" "nala" "Audio tag editor" || log WARN "Puddletag installation failed, continuing..."
                ;;

            "brasero")
                install_package_secure "Brasero" "brasero" "nala" "Disc burning for GNOME" || log WARN "Brasero installation failed, continuing..."
                ;;

            "k3b")
                install_package_secure "K3B" "k3b" "nala" "Disc burning for KDE" || log WARN "K3B installation failed, continuing..."
                ;;

            "makemkv")
                show_message "Manual Installation" "MakeMKV requires manual installation:\n\n1. Visit: https://www.makemkv.com/download/\n2. Download Linux version\n3. Follow installation instructions\n\nNote: Free while in beta."
                xdg-open "https://www.makemkv.com/download/" 2>/dev/null &
                ;;

            "cheese")
                install_package_secure "Cheese" "cheese" "nala" "Webcam application" || log WARN "Cheese installation failed, continuing..."
                ;;

            "guvcview")
                install_package_secure "GuvcView" "guvcview" "nala" "Webcam viewer" || log WARN "GuvcView installation failed, continuing..."
                ;;

            "vokoscreen")
                install_package_secure "vokoscreen" "vokoscreen-ng" "nala" "Screencast creator" || log WARN "vokoscreen installation failed, continuing..."
                ;;

            "green-recorder")
                install_package_secure "Green Recorder" "green-recorder" "flatpak" "Simple screen recorder" || log WARN "Green Recorder installation failed, continuing..."
                ;;

            "pinta")
                install_package_secure "Pinta" "pinta" "nala" "Simple image editor" || log WARN "Pinta installation failed, continuing..."
                ;;

            "mypaint")
                install_package_secure "MyPaint" "mypaint" "nala" "Painting application" || log WARN "MyPaint installation failed, continuing..."
                ;;

            "natron")
                install_package_secure "Natron" "natron" "snap" "Compositing software" || log WARN "Natron installation failed, continuing..."
                ;;

            "synfigstudio")
                install_package_secure "Synfig Studio" "synfigstudio" "nala" "2D animation software" || log WARN "Synfig Studio installation failed, continuing..."
                ;;

            "opentoonz")
                install_package_secure "OpenToonz" "opentoonz" "snap" "2D animation production" || log WARN "OpenToonz installation failed, continuing..."
                ;;

            "pulseaudio")
                install_package_secure "PulseAudio Tools" "pulseaudio pulseaudio-utils" "nala" "Audio control utilities" || log WARN "PulseAudio installation failed, continuing..."
                ;;

            "pavucontrol")
                install_package_secure "PavuControl" "pavucontrol" "nala" "PulseAudio volume control" || log WARN "PavuControl installation failed, continuing..."
                ;;

            "easyeffects")
                install_package_secure "EasyEffects" "easyeffects" "flatpak" "Audio effects" || log WARN "EasyEffects installation failed, continuing..."
                ;;

            "carla")
                install_package_secure "Carla" "carla" "nala" "Audio plugin host" || log WARN "Carla installation failed, continuing..."
                ;;

            "qjackctl")
                install_package_secure "QjackCtl" "qjackctl" "nala" "JACK audio control" || log WARN "QjackCtl installation failed, continuing..."
                ;;

            "hydrogen")
                install_package_secure "Hydrogen" "hydrogen" "nala" "Drum machine" || log WARN "Hydrogen installation failed, continuing..."
                ;;

            "musescore")
                install_package_secure "MuseScore" "musescore" "snap" "Music notation software" || log WARN "MuseScore installation failed, continuing..."
                ;;

            "tuxguitar")
                install_package_secure "TuxGuitar" "tuxguitar" "nala" "Guitar tablature editor" || log WARN "TuxGuitar installation failed, continuing..."
                ;;
        esac
    done

    show_message "Completed" "Multimedia tools installation completed!\n\nNote: Some applications may require additional codecs or plugins for full functionality."
}