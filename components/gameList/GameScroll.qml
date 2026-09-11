import QtQuick 2.15
import QtGraphicalEffects 1.12

import '../media' as Media

Item {

    // signal imageLoaded(int imgWidth, int imgHeight)

    property alias video: gameListVideo;
    property alias gamesGridView: gamesGridView;
    property alias gamesListView: gamesListView;
    property var sortingFont: global.fonts.sans;
    property alias letter: skipLetter.letter;

    property double itemHeight: {
        return gamesListView.height * .1 * theme.fontScale;
    }

    property string imgBoxFront: {
        if (currentGame === null) return '';
        return currentGame.assets.boxFront;
    }

    property string imgScreenshot: {
        if (currentGame === null) return '';
        return currentGame.assets.screenshot;
    }

    property string imgLogo: {
        if (currentGame === null) return '';
        return currentGame.assets.logo;
    }

    property var ratingText: {
        if (currentGame === null) return '';
        if (currentGame.rating === 0) return '';

        let stars = [];
        const rating = Math.round(currentGame.rating * 500) / 100;

        for (let i = 0; i < 5; i++) {
            if (rating - i <= 0) {
                stars.push(glyphs.emptyStar);
            } else if (rating - i < 1) {
                stars.push(glyphs.halfStar);
            } else {
                stars.push(glyphs.fullStar);
            }
        }
        return stars.join(' ');
    }

    property string releaseDateText: {
        if (currentGame === null) return '';
        if (!currentGame.releaseYear) return '';
        return currentGame.releaseYear;
    }

    property string playersText: {
        if (currentGame === null) return '';
        if (!currentGame.players) return '';
        return currentGame.players + 'P';
    }

    property string genreText: {
        if (currentGame === null) return '';

        if (currentGame.genreList.length === 0) { return null; }

        const genre = currentGame.genreList[0] ?? '';
        const split = genre.split(',');

        if (split[0].length === 0) { return null; }

        return split[0];
    }

    property string lastPlayedText: {
        if (currentGame === null) return '';

        const lastPlayed = currentGame.lastPlayed.getTime();
        if (isNaN(lastPlayed)) return 'Never played';

        const now = new Date().getTime();

        let time = Math.floor((now - lastPlayed) / 1000);
        if (time < 60) {
            return 'Played ' + time + ' seconds ago';
        }

        time = Math.floor(time / 60);
        if (time < 60) {
            return 'Played ' + time + ' minutes ago';
        }

        time = Math.floor(time / 60);
        if (time < 24) {
            return 'Played ' + time + ' hours ago';
        }

        time = Math.floor(time / 24);
        return 'Played ' + time + ' days ago';
    }

    property var sortingText: {
        if (sortKey === 'release') {
            sortingFont = global.fonts.sans;
            return gameData.releaseDateText;
        }

        if (sortKey === 'rating') {
            sortingFont = glyphs.name;
            return gameData.ratingText;
        }

        sortingFont = global.fonts.sans;
        return gameData.lastPlayedText;
    }

    property string noGameText: {
        if (nameFilter != '') {
            return 'No Games With "' + nameFilter + '"';
        }
        return 'No Games';
    }

    function alwaysListView() {
        return currentShortName=='allgames' || currentShortName=='favorites' || settings.get('alwaysListView');
    }

    Component.onCompleted: {
        gamesGridView.currentIndex = currentGameIndex;
        gamesGridView.positionViewAtIndex(currentGameIndex, ListView.Center);
        
        theme.setGridViewScale(settings.get('showDetail'));
        settings.addCallback('gameListVideo', function () {
            gameListVideo.switchVideo();
        });
    }

    Text {
        visible: currentGameList.count === 0;
        text: noGameText;
        anchors.centerIn: parent;
        color: theme.current.blurTextColor;
        opacity: 0.5;

        font {
            pixelSize: parent.height * .065;
            letterSpacing: -0.3;
            bold: true;
        }
    }

    ListView {
        id: gamesListView;
        visible: alwaysListView();
        model: currentGameList;
        delegate: lvGameDelegate;

        width: parent.width * theme.gridViewScale - 20; // 20 is left margin
        height: parent.height - 24;
        highlightMoveDuration: 0;
        preferredHighlightBegin: itemHeight - 12; // height of an item minus top margin
        preferredHighlightEnd: parent.height - (itemHeight + 12); // height of an item plus bottom margin
        highlightRangeMode: ListView.ApplyRange;

        anchors {
            left: parent.left;
            leftMargin: 20;
            top: parent.top;
            topMargin: 12;
            bottom: parent.bottom;
            bottomMargin: 12;
        }

        highlight: Rectangle {
            color: collectionData.getColor(currentShortName);
            opacity: theme.current.bgOpacity;
            radius: 8;
            width: gamesListView.width;
        }

        onCurrentIndexChanged: {
            gameListVideo.switchVideo();
        }
    }

    Component {
        id: lvGameDelegate;
        GameItem {
            width: gamesGridView.width;
            height: itemHeight;
        }
    }

    GridView{
        id: gamesGridView;
        model: currentGameList;
        visible: !alwaysListView();
        
        anchors.leftMargin: 60;
        width: parent.width * theme.gridViewScale - 20; // 20 is left margin
        height: parent.height - 80;

        highlightRangeMode: GridView.StrictlyEnforceRange;
        preferredHighlightBegin: 40 *  theme.gridViewScale;
        preferredHighlightEnd: parent.height;

        property real columnCount: {
            if (cellHeightRatio > 1.2) return 5;
            if (cellHeightRatio > 0.6) return 4;
            return 3;
        }
        readonly property int maxRecalcs: 5
        property int currentRecalcs: 0
        property real cellHeightRatio: 0.5

        cellWidth: width / columnCount
        cellHeight: cellWidth * cellHeightRatio;
        
        delegate: Media.GameGridItem {
            width: GridView.view.cellWidth;
            height: GridView.view.cellHeight;
            selected: GridView.isCurrentItem

            game: modelData

            onClicked: GridView.view.currentIndex = index
            onDoubleClicked: {
                GridView.view.currentIndex = index;
                root.detailsRequested();
            }
            Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    root.launchRequested();
                }
            }

            onImageLoaded: {
                gamesGridView.columnCount = collectionData.getColumnCount(currentShortName);
                gamesGridView.cellHeightRatio = collectionData.getRatio(currentShortName);
                if(!settings.get('showDetail')){
                    gamesGridView.columnCount += 1;
                }
            }
        }
    
    }

    SkipLetter {
        id: skipLetter;
        anchors {
            verticalCenter: gamesGridView.verticalCenter;
            horizontalCenter: gamesGridView.horizontalCenter;
        }
    }

    /* Vertical pane with rating, players, date */
    VerticalPane {
        id: verticalPane;
        width: vpx(20);
        visible:false;
        anchors {
            top: parent.top;
            topMargin: vpx(10);
            bottom: parent.bottom;
            bottomMargin: vpx(10);
            right: parent.right;
            rightMargin: vpx(22);
        }
    }

    // right side
    Rectangle {
        color: 'transparent';
        width:  parent.width * 0.45 - vpx(62);
        height: parent.height;
        anchors.left: gamesGridView.right;
        anchors.leftMargin: 10;

        Media.GameImage {
            id: gameListScreenshot;
            height: parent.height / 2;
            anchors {
                bottom: parent.bottom;
                left: parent.left;
                leftMargin: vpx(20);
                right: parent.right;
                rightMargin: vpx(10);
            }
            imageSource: imgScreenshot;
        }

        Media.GameVideo {
            id: gameListVideo;

            height: parent.height / 2;
            anchors {
                top: parent.top;
                topMargin: vpx(20);
                left: parent.left;
                leftMargin: vpx(70);
                right: parent.right;
                rightMargin: vpx(10);
            }
            settingKey: 'gameListVideo';
            validView: 'gameList';

            onVideoToggled: {
                gameListScreenshot.videoPlaying = videoPlaying;
            }
        }

        Rectangle {
            color: 'transparent';
            height:parent.height / 2 - 50;
            anchors {
                top: parent.top;
                left: parent.left;
                right: parent.right;
                bottom: gameScrollBottomText.top;
                topMargin:vpx(10);
                leftMargin:vpx(10);
                rightMargin:vpx(10);
            }
            Text {
                id: genre;
                text: genreText;

                color: theme.current.detailsColor;
                opacity: .7;
                elide: Text.ElideRight;
                maximumLineCount: 2;
                wrapMode: Text.WordWrap;
                horizontalAlignment: Text.AlignHCenter;

                font {
                    family: glyphs.name;
                    pixelSize: parent.height * .125 * theme.fontScale;
                    bold: true;
                }

                width: parent.width;
                anchors {
                    bottom: lastPlayed.top;
                }
            }

            Media.GameImage {
                id: gameListLogo;
                anchors {
                    fill: parent;
                }
                imageSource: imgLogo;
            }
        }

        Rectangle{
            id: gameScrollBottomText;
            width:parent.width-20;
            color: 'transparent';
            height:vpx(40);
            anchors{
                bottom:gameListScreenshot.top;
                horizontalCenter:parent.horizontalCenter;
            }
            Text{
                text: currentGame.developer + ' - ' +currentGame.releaseYear;
                color:theme.current.blurTextColor;
                font {
                    pixelSize: parent.height * .5;
                    letterSpacing: -0.3;
                    bold: true;
                }
                anchors.horizontalCenter:parent.horizontalCenter;
                anchors.verticalCenter:parent.verticalCenter;
                wrapMode: Text.WordWrap;
            }
        }
    }
}
