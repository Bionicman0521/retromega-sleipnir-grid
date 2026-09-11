import QtQuick 2.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2

Item {
    MouseArea {
        anchors.fill: parent;
        onClicked: {
            collectionListView.currentIndex = index;
            onAcceptPressed();
        }
    }

    // background stripe
    Image {
        source: '../../assets/images/stripe.png';
        fillMode: Image.PreserveAspectFit;
        horizontalAlignment: Image.AlignHCenter;

        anchors {
            fill: parent;
            leftMargin: 70;
        }
    }


    Image {
        id: charecters;

        source: '../../assets/images/charecters/' + collectionData.getImage(modelData.shortName) + '.png';
        width: parent.width;
        height: parent.height;
        fillMode: Image.PreserveAspectFit;
        horizontalAlignment: Image.AlignRight;
        asynchronous: true;
        smooth: true;
        visible: true;

        anchors {
            right: parent.right;
            bottom:parent.bottom;
            top:parent.top;
        }
    }

    // new
    Image {
        id : consoleLogo
        width: root.width * .4;
        height: root.height * .3;
        scale: selected ? 1.0 : 0.555;
        z:1;
        fillMode: Image.PreserveAspectFit;
        anchors {
            verticalCenter: parent.verticalCenter;
            left: parent.left;
            leftMargin: 60;
        }
        source: '../../assets/images/logos/' + collectionData.getImage(modelData.shortName) + '.png';
    }

    DropShadow {
        source: consoleLogo;
        horizontalOffset: 15;
        verticalOffset: 15;
        z:1;
        color:theme.current.dropShadowColor;
        radius: vpx(20);
        samples: 41;
        cached: true;
        anchors.fill: consoleLogo;
    }

    Text {
        text: filteredGamesCollection.count + ' GAMES';
        color: theme.current.titleColor;
        opacity: 0.7;

        anchors {
            left: parent.left;
            leftMargin: 60;
            top: consoleLogo.bottom;
            topMargin: root.height * .02;
        }

        font {
            pixelSize: root.height * .025;
            letterSpacing: -0.3;
            bold: true;
        }
    }

    SortFilterProxyModel {
        id: filteredGamesCollection;

        sourceModel: allCollections[collectionListView.currentIndex].games;
        filters: [
            ValueFilter { roleName: 'favorite'; value: true; enabled: onlyFavorites; },
            ExpressionFilter { enabled: onlyMultiplayer; expression: { return players > 1; } },
            RegExpFilter { roleName: 'title'; pattern: nameFilter; caseSensitivity: Qt.CaseInsensitive; enabled: nameFilter !== ''; }
        ]
    }

    Text {
        id: venderyear;
        text: collectionData.getVendorYear(modelData.shortName);
        color: theme.current.titleColor;
        opacity: 0.7;

        font {
            capitalization: Font.AllUppercase;
            pixelSize: root.height * .025;
            letterSpacing: 1.3;
            bold: true;
        }

        anchors {
            left: parent.left;
            leftMargin: 60;
            bottom: consoleLogo.top;
            bottomMargin: root.height * .02;
        }
    }

    DropShadow {
        source: charecters;
        horizontalOffset: 15;
        verticalOffset: 15;
        color:theme.current.dropShadowColor;
        radius: vpx(20);
        samples: 41;
        cached: true;
        anchors.fill: charecters;
    }
}
