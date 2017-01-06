using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class darktimesApp extends App.AppBase {

	var view;
	
    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
		view = new darktimesView();
        return [ view ];
    }
    
    function onSettingsChanged() {
    	view.loadSettings = true;
    	Ui.requestUpdate();
    }
}