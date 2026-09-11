import QtQuick 2.15

import '../footer' as Footer
import '../header' as Header

Flickable {
    anchors.fill: parent;

    flickableDirection: Flickable.HorizontalFlick
    onFlickStarted: {
        if (horizontalVelocity < 0) {
            const updated = updateCollectionIndex(currentCollectionIndex - 1);
            if (updated) {
                updateSortedCollection();
                sounds.nav();
                gameScroll.video.switchVideo();
            }
        }
        if (horizontalVelocity > 0) {
            const updated = updateCollectionIndex(currentCollectionIndex + 1);
            if (updated) {
                updateSortedCollection();
                sounds.nav();
                gameScroll.video.switchVideo();
            }
        }
    }
    boundsMovement: Flickable.StopAtBounds
    pressDelay: 0

    function alwaysListView() {
        return currentShortName=='allgames' || currentShortName=='favorites' || settings.get('alwaysListView');
    }
    
    function updateIndex(newIndex, moveAnimation=false) {
        if(alwaysListView()) {
            if(moveAnimation)
            gameScroll.gamesListView.highlightMoveDuration = 225;
            gameScroll.gamesListView.currentIndex = newIndex;
            if(moveAnimation)
                gameScroll.gamesListView.highlightMoveDuration = 0;
        }
        if(moveAnimation)
            gameScroll.gamesGridView.highlightMoveDuration = 225;
        gameScroll.gamesGridView.currentIndex = newIndex;
        if(moveAnimation)
            gameScroll.gamesGridView.highlightMoveDuration = 0;   
    }

    Keys.onLeftPressed: {
        event.accepted = true;
        if(alwaysListView()){
            event.accepted = true;
            if (currentGameIndex === 0) return;

            let newIndex = currentGameIndex - 1;
            const oldGame = getMappedGame(newIndex);
            const oldLetter = oldGame.sortBy[0].toLowerCase();

            while (newIndex > 0) {
                const newGame = getMappedGame(newIndex - 1);
                const newLetter = newGame.sortBy[0].toLowerCase();
                if (newLetter !== oldLetter) {
                     break;
                }
                 newIndex--;
            }

            const updated = updateGameIndex(newIndex);
            if (updated) {
                gameScroll.letter = currentGame.title[0].toUpperCase();
                sounds.nav();
            }
            return;
        }
        const updated = updateGameIndex(currentGameIndex - 1);
        if (updated) { sounds.nav(); }
    }

    Keys.onRightPressed: {
        event.accepted = true;
        if(alwaysListView()){
            event.accepted = true;
            if (currentGameIndex === currentGameList.count - 1) return;
            const oldLetter = currentGame.sortBy[0].toLowerCase();
            let newIndex = currentGameIndex;

            while (newIndex < currentGameList.count - 1) {
                newIndex++;
                const newGame = getMappedGame(newIndex);
                const newLetter = newGame.sortBy[0].toLowerCase();
                if (newLetter !== oldLetter) {
                    break;
                }
            }

            const updated = updateGameIndex(newIndex);
            if (updated) {
                gameScroll.letter = currentGame.title[0].toUpperCase();
                sounds.nav();
            }
            return;
        }
        const updated = updateGameIndex(currentGameIndex + 1);
        if (updated) { sounds.nav(); }
    }

    Keys.onUpPressed: {
        event.accepted = true;
        if(alwaysListView()){
            updateGameIndex(currentGameIndex - 1);
            return;
        }
        let new_index = currentGameIndex - gameScroll.gamesGridView.columnCount
        const updated = updateGameIndex(new_index>=0?new_index:currentGameIndex);
        if (updated) { sounds.nav(); }
    }

    Keys.onDownPressed: {
        event.accepted = true;
        // if(currentShortName=='allgames' || currentShortName=='favorites'){
        if(alwaysListView()){
            updateGameIndex(currentGameIndex + 1);
            return;
        }
        let new_index = currentGameIndex + gameScroll.gamesGridView.columnCount
        const updated = updateGameIndex(new_index > (currentGameList.count-1) ? currentGameIndex: new_index);
        if (updated) { sounds.nav(); }
    }

    function onAcceptPressed() {
        if (currentGameList.count === 0) return;
        sounds.launch();
        currentGame.launch();
    }

    function onCancelPressed() {
        currentView = 'collectionList';
        updateGameIndex(0, true);
        sounds.back();
    }

    function onDetailsPressed() {
        currentView = 'gameDetails';
        sounds.forward();
    }

    function onFiltersPressed() {
        const gameCount = currentGameList.count;
        const randomIndex = Math.floor(Math.random() * gameCount);
        updateGameIndex(randomIndex);
        sounds.nav();
    }

    Keys.onPressed: {

        if (api.keys.isPageUp(event) || api.keys.isPageDown(event)) {
                event.accepted = true;
                var rows_to_skip = Math.max(1, Math.round(gamesGridView.height / cellHeight));
                var games_to_skip = rows_to_skip * columnCount;
                if (api.keys.isPageUp(event)){
                    let new_index = Math.max(currentGameIndex - games_to_skip, 0);
                    const updated = updateGameIndex(new_index);
                }
                else{
                    let  new_index = Math.min(currentGameIndex + games_to_skip, model.count - 1);
                    const updated = updateGameIndex(new_index);
                }
            }

        if (api.keys.isCancel(event)) {
            event.accepted = true;
            onCancelPressed();
        }

        if (api.keys.isAccept(event)) {
            event.accepted = true;
            onAcceptPressed();
        }

        if (api.keys.isDetails(event)) {
            event.accepted = true;
            onDetailsPressed();
        }

        if (api.keys.isFilters(event)) {
            event.accepted = true;
            onFiltersPressed();
        }

        // L1
        if (api.keys.isPrevPage(event)) {
            const updated = updateCollectionIndex(currentCollectionIndex - 1);
            if (updated) {
                updateSortedCollection();
                sounds.nav();
                gameScroll.video.switchVideo();
            }
        }

        // R1
        if (api.keys.isNextPage(event)) {
            
            const updated = updateCollectionIndex(currentCollectionIndex + 1);
            if (updated) {
                updateSortedCollection();
                sounds.nav();
                gameScroll.video.switchVideo();
            }
        }
    }

    function onFavoritePressed() {
        if (currentGameList.count === 0 || onlyFavorites) return;

        currentGame.favorite = !currentGame.favorite;
        sounds.nav();
    }

    // todo keep an eye on this issue https://github.com/mmatyas/pegasus-frontend/issues/781
    // R2 and L2 must be handled 'onRelease' because of an android bug that requires double presses
    Keys.onReleased: {
        // R2
        if (api.keys.isPageDown(event)) {
            event.accepted = true;
            previousView = currentView;
            currentView = 'sorting';
            sounds.forward();
        }

        //L2
        if (api.keys.isPageUp(event)) {
            event.accepted = true;
            onFavoritePressed();
        }
    }

    Rectangle {
        color: theme.current.bgColor;
        anchors.fill: parent;
    }

    GameScroll {
        id: gameScroll;
        letter: '';

        anchors {
            top: gameListHeader.bottom;
            bottom: gameListFooter.top;
            left: parent.left;
            right: parent.right;
            leftMargin: 20;
            bottomMargin:20;
        }
    }

    Footer.Component {
        id: gameListFooter;

        index: currentGameIndex + 1;
        total: currentGameList.count;

        buttons: [
            { title: 'Play', key: theme.buttonGuide.accept, square: false, sigValue: 'accept' },
            { title: 'Back', key: theme.buttonGuide.cancel, square: false, sigValue: 'cancel' },
            { title: 'Details', key: theme.buttonGuide.details, square: false, sigValue: 'details' },
            { title: 'Random', key: theme.buttonGuide.filters, square: false, sigValue: 'filters' },
            { title: 'Favorite', visible: !onlyFavorites, key: theme.buttonGuide.pageUp, square: true, sigValue: 'favorite' }
        ];

        onFooterButtonClicked: {
            if (sigValue === 'accept') onAcceptPressed();
            if (sigValue === 'cancel') onCancelPressed();
            if (sigValue === 'details') onDetailsPressed();
            if (sigValue === 'filters') onFiltersPressed();
            if (sigValue === 'favorite') onFavoritePressed();
        }
    }

    Header.Component {
        id: gameListHeader;
        showDivider: true;
        shade: 'dark';
        color: theme.current.bgColor;
        showTitle: true;
        z:0;
    }
}
