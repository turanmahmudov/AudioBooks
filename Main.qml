import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import QtQuick.XmlListModel 2.0
import QtMultimedia 5.0
import "js/scripts.js" as Scripts

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "audiobooks.turan-mahmudov-l"

    // Rotation
    automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(50)
    height: units.gu(75)

    property var active_index : 0

    Audio {
        id: player
        onVolumeChanged: {  }
        onSourceChanged: {  }
        onStopped: {
            if(status == Audio.EndOfMedia) {
                Scripts.playNextSong();
            }
        }
        onPositionChanged: {
            //playingstate.width=mainView.width*(position/duration);
        }
        onBufferProgressChanged: { }
        onPlaybackStateChanged: { }
    }

    PageStack {
        id: pageStack

        Component.onCompleted: {
            pageStack.push(mainPage);
            Scripts.get_catalog();
        }
    }

    Page {
        id: mainPage
        title: i18n.tr("Audio Books")
        state: "default"
        states: [
            PageHeadState {
                name: "default"
                head: mainPage.head
                actions: [
                    Action {
                        iconName: "search"
                        onTriggered: mainPage.state = "search"
                    }
                ]
            },
            PageHeadState {
                id: headerState
                name: "search"
                head: mainPage.head
                backAction: Action {
                    id: leaveSearchAction
                    text: "back"
                    iconName: "back"
                    onTriggered: {
                        mainPage.state = "default"
                        Scripts.get_catalog();
                    }
                }
                contents: TextField {
                    id: searchField
                    anchors {
                        right: parent.right
                        rightMargin: units.gu(2)
                    }
                    hasClearButton: true
                    inputMethodHints: Qt.ImhNoPredictiveText
                    placeholderText: i18n.tr("Search books")
                    onVisibleChanged: {
                        if (visible) {
                            forceActiveFocus()
                        }
                    }
                    onAccepted: {
                        Scripts.search_book(searchField.text);
                        pageStack.push(searchPage);
                    }
                }
            }
        ]

        Item {
            anchors.fill: parent

            ListModel {
                id: mainCatalogListModel
            }

            ListItem.Header {
                id: mainCatalogListHeader
                text: i18n.tr("Catalog")
            }

            ListView {
                id: mainCatalogListView
                width: parent.width
                height: units.gu(18)
                anchors {
                    top: mainCatalogListHeader.bottom
                }
                orientation: Qt.Horizontal
                highlightMoveDuration: UbuntuAnimation.FastDuration

                model: mainCatalogListModel
                delegate: ListItem.Empty {
                    width: units.gu(15)
                    height: width*6/5
                    showDivider: false
                    Rectangle {
                        width: parent.width-units.gu(1)
                        height: parent.height
                        anchors {
                            rightMargin: i+1 < mainCatalogListModel.count ? units.gu(1) : 0
                        }
                        color: i%3 == 0 ? "#007938" : i%3 == 1 ? "#009ee1" : "#fbc340"
                        Image {
                            anchors.fill: parent
                            source: image
                        }
                        Rectangle {
                            anchors {
                                bottom: parent.bottom
                            }
                            height: parent.height/4
                            width: parent.width
                            color: "#000000"
                            opacity: 0.8
                            Label {
                                id: booktitle
                                anchors {
                                    top: parent.top
                                    topMargin: units.gu(0.2)
                                }
                                horizontalAlignment: Text.AlignHCenter
                                maximumLineCount: 1
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                text: title
                                width: parent.width
                                fontSize: "x-small"
                                color: "#ffffff"
                            }
                            Label {
                                id: bookauthor
                                anchors {
                                    top: booktitle.bottom
                                }
                                horizontalAlignment: Text.AlignHCenter
                                maximumLineCount: 1
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                text: author
                                width: parent.width
                                fontSize: "x-small"
                                color: "#ffffff"
                            }
                        }
                    }

                    onClicked: {
                        Scripts.get_book_rss(id);
                        Scripts.get_book(id, image, archivelink);
                    }
                }
            }
        }
    }

    Page {
        id: searchPage
        title: i18n.tr("Search Results")
        visible: false

        Item {
            anchors.fill: parent

            ListModel {
                id: searchCatalogListModel
            }

            ListView {
                id: searchCatalogListView
                width: parent.width
                height: parent.height
                clip: true
                anchors {
                    top: parent.top
                }
                highlightMoveDuration: UbuntuAnimation.FastDuration

                model: searchCatalogListModel
                delegate: ListItem.Empty {
                    width: parent.width
                    height: booktitle.height + bookauthor.height + units.gu(3)

                    Label {
                        id: booktitle
                        anchors {
                            top: parent.top
                            topMargin: units.gu(1)
                            left: parent.left
                            leftMargin: units.gu(1)
                            right: parent.right
                            rightMargin: units.gu(1)
                        }
                        maximumLineCount: 1
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        text: title
                        width: parent.width
                    }
                    Label {
                        id: bookauthor
                        anchors {
                            top: booktitle.bottom
                            topMargin: units.gu(1)
                            left: parent.left
                            leftMargin: units.gu(1)
                            right: parent.right
                            rightMargin: units.gu(1)
                        }
                        maximumLineCount: 1
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        text: author
                        width: parent.width
                    }

                    onClicked: {
                        Scripts.get_book_rss(id);
                        Scripts.get_book(id, image, archivelink);
                    }
                }
            }
        }
    }

    Page {
        id: bookPage
        title: i18n.tr("Book")
        visible: false

        head {
            sections {
                model: ["Listen", "Chapters", "Description"]
                onSelectedIndexChanged: {
                    Scripts.changeIndex(bookPage.head.sections.selectedIndex);
                }
            }
        }

        Item {
            id: bookListenItem
            anchors.fill: parent

            Image {
                id: bookImage
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width*3/5
                height: width*6/5
            }

            Item {
                id: toolbarContainer
                anchors.left: parent.left
                anchors.leftMargin: units.gu(3)
                anchors.right: parent.right
                anchors.rightMargin: units.gu(3)
                anchors.bottom: musicToolbarFullContainer.top
                anchors.bottomMargin: units.gu(4)
                height: units.gu(2)
                width: parent.width

                Label {
                    id: toolbarPositionLabel
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(1.4)
                    color: "#2E6D7D"
                    fontSize: "small"
                    height: parent.height
                    horizontalAlignment: Text.AlignHCenter
                    text: Scripts.durationToString(player.position)
                    verticalAlignment: Text.AlignVCenter
                    width: units.gu(3)
                }

                Rectangle {
                    id: progressSlider
                    anchors.left: toolbarPositionLabel.right
                    anchors.leftMargin: units.gu(2)
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(2.2)
                    height: units.gu(0.5)
                    width: 0
                    color: "#2E6D7D"
                }

                Rectangle {
                    id: progressSliderBack
                    anchors.left: toolbarPositionLabel.right
                    anchors.leftMargin: units.gu(2)
                    anchors.right: toolbarDurationLabel.left
                    anchors.rightMargin: units.gu(2)
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(2.2)
                    height: units.gu(0.5)
                    color: "#fff"
                    opacity: 0.1

                    Connections {
                        target: player
                        onPositionChanged: {
                            progressSlider.width = progressSliderBack.width*(player.position/player.duration);

                            toolbarPositionLabel.text = Scripts.durationToString(player.position)
                            toolbarDurationLabel.text = Scripts.durationToString(player.duration)
                        }
                        onStopped: {
                            toolbarPositionLabel.text = Scripts.durationToString(0);
                            toolbarDurationLabel.text = Scripts.durationToString(0);
                        }
                    }
                }

                /* Duration label */
                Label {
                    id: toolbarDurationLabel
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(1.4)
                    color: "#2E6D7D"
                    fontSize: "small"
                    height: parent.height
                    horizontalAlignment: Text.AlignHCenter
                    text: Scripts.durationToString(player.duration)
                    verticalAlignment: Text.AlignVCenter
                    width: units.gu(3)
                }
            }

            /* Full toolbar */
            Rectangle {
                id: musicToolbarFullContainer
                anchors.bottom: parent.bottom
                height: units.gu(7)
                width: parent.width
                color: "transparent"

                /* Previous button */
                MouseArea {
                    id: nowPlayingPreviousButton
                    anchors.right: nowPlayingPlayButton.left
                    anchors.rightMargin: units.gu(1)
                    anchors.verticalCenter: nowPlayingPlayButton.verticalCenter
                    height: units.gu(6)
                    opacity: 1
                    width: height
                    onClicked: Scripts.playPrevSong()

                    Icon {
                        id: nowPlayingPreviousIndicator
                        height: units.gu(3)
                        width: height
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#2E6D7D"
                        name: "media-skip-backward"
                        opacity: 1
                    }
                }

                /* Play/Pause button */
                MouseArea {
                    id: nowPlayingPlayButton
                    anchors.centerIn: parent
                    height: units.gu(6)
                    width: height
                    onClicked: {
                        if (player.playbackState === MediaPlayer.PlayingState) {
                            player.pause();
                        } else {
                            if (player.source == '') {
                                active_index = 0;
                                player.source = bookChaptersModel.get(0).mp3_link;
                                player.play();
                            } else {
                                player.play();
                            }
                        }
                    }

                    Icon {
                        id: nowPlayingPlayIndicator
                        height: units.gu(5)
                        width: height
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 1
                        color: "#2E6D7D"
                        name: player.playbackState === MediaPlayer.PlayingState ?
                                  "media-playback-pause" :
                                  "media-playback-start"
                    }
                }

                /* Next button */
                MouseArea {
                    id: nowPlayingNextButton
                    anchors.left: nowPlayingPlayButton.right
                    anchors.leftMargin: units.gu(1)
                    anchors.verticalCenter: nowPlayingPlayButton.verticalCenter
                    height: units.gu(6)
                    opacity: 1
                    width: height
                    onClicked: Scripts.playNextSong()

                    Icon {
                        id: nowPlayingNextIndicator
                        height: units.gu(3)
                        width: height
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#2E6D7D"
                        name: "media-skip-forward"
                        opacity: 1
                    }
                }
            }
        }

        Item {
            id: bookChaptersItem
            anchors.fill: parent
            visible: false

            XmlListModel {
                id: bookChaptersModel
                query: "/rss/channel/item[child::itunes:duration]"
                namespaceDeclarations: "declare namespace itunes = 'http://www.itunes.com/dtds/podcast-1.0.dtd';"

                XmlRole { name: "title"; query: "title/string()" }
                XmlRole { name: "mp3_link"; query: "link/string()" }
                XmlRole { name: "duration"; query: "itunes:duration/string()" }
            }

            ListView {
                id: bookChaptersListView
                width: parent.width
                height: parent.height
                clip: true

                model: bookChaptersModel
                delegate: ListItem.Empty {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    width: parent.width - units.gu(4)
                    height: units.gu(4)
                    Label {
                        id: ttl
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(1)
                        width: parent.width - drtn.width - units.gu(1)
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        text: title
                    }

                    Label {
                        id: drtn
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(1)
                        anchors.right: parent.right
                        text: duration
                    }

                    onClicked: {
                        active_index = index;
                        player.source = mp3_link;
                        player.play();
                    }
                }
            }
        }

        Item {
            id: bookDescriptionItem
            anchors.fill: parent
            visible: false

            Flickable {
                id: flickable
                anchors.fill: parent
                clip: true
                contentHeight: bookDescriptionLabel.height

                Label {
                    id: bookDescriptionLabel
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(1)
                    width: parent.width - units.gu(4)
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    Item {
        id: indicator
        anchors.centerIn: parent
        opacity: 0

        Behavior on opacity {
            UbuntuNumberAnimation {
                duration: UbuntuAnimation.SlowDuration
            }
        }

        ActivityIndicator {
            id: activity
            running: true
        }
    }
}

