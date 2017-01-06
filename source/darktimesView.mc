using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Application as App;

class darktimesView extends Ui.WatchFace {
	// globals
	var loadSettings = true;
	var countFont = Gfx.FONT_NUMBER_MEDIUM;
	var dateFont = Gfx.FONT_SYSTEM_LARGE;
	var timeFont;
	var batFont = Gfx.FONT_SYSTEM_LARGE; //NUMBER_MILD;
	var w;
	var h;
	var on = true;
	var showCount; // = false;
	var showBat; // = false;
	var batWarning = 15;
	var batWarningCol; // = Gfx.COLOR_PINK;
	var timeOnCol = Gfx.COLOR_WHITE;
	var timeOffCol; // = Gfx.COLOR_BLACK;
	var btCol; // = Gfx.COLOR_DK_GRAY;
	var alarmCol; // = Gfx.COLOR_LT_GRAY;
	var bgCol; //Gfx.COLOR_BLACK;
	var msgCol; //Gfx.COLOR_WHITE;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    	w = dc.getWidth();
		h = dc.getHeight();
		timeFont = Ui.loadResource(Rez.Fonts.id_theFont);
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    	if (loadSettings) {
    		getSettings();
    		loadSettings = false;
    	}
		// clear background and show messages/alarms
    	drawBG(dc);
    	drawMsg(dc);

		// draw time or not
    	if (on) {
	        dc.setColor(timeOnCol, Gfx.COLOR_TRANSPARENT);
    		drawTime(dc);
    		drawBat(dc);
    	} else if (timeOffCol != Gfx.COLOR_BLACK) {
	        dc.setColor(timeOffCol, Gfx.COLOR_TRANSPARENT);
    		drawTime(dc);
    		drawBat(dc);
    	} else if (showBat) {
	        dc.setColor(timeOnCol, Gfx.COLOR_TRANSPARENT);
    		drawBat(dc);
    	}
    }

	function drawMsg(dc) {

		var settings = Sys.getDeviceSettings();
		var conn = settings.phoneConnected;

		if (conn) {

			var msgs = settings.notificationCount;
			var alarms = settings.alarmCount;
			
			if (msgs > 0) {
		        dc.setColor(msgCol, Gfx.COLOR_TRANSPARENT);
				dc.fillRoundedRectangle((w >> 1) + 2, 3*h >> 2, (w >> 1) - 22, h >> 2, 8);

				if (on && showCount) {
		        	dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
					dc.drawText((w >> 1) + (w >> 3), h/3 << 1 + 10, countFont, msgs.format("%d"), Gfx.TEXT_JUSTIFY_CENTER);
				}
			}

			if (alarms > 0){
		        dc.setColor(alarmCol, Gfx.COLOR_TRANSPARENT);
				dc.fillRoundedRectangle( w >> 2, 3*h >> 2, (w >> 2), h >> 2, 8);

				if (on && showCount) {
					dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
					dc.drawText((w >> 1) - (w >> 3), h/3 << 1 + 10, countFont, alarms.format("%d"), Gfx.TEXT_JUSTIFY_CENTER);
				}
			}

	        dc.setColor(btCol, Gfx.COLOR_TRANSPARENT);
			dc.fillRoundedRectangle( 19, 3*h/4, (w >> 2) - 22, h >> 2, 8);
		}
	}
	    
    function drawBG(dc) {

        dc.setColor(0, bgCol);
        dc.clear();
    }
    
    function drawTime(dc) {

        var now = Calendar.info(Time.now(), Time.FORMAT_MEDIUM);
        var timeStr = Lang.format("$1$:$2$", [now.hour.format("%02d"), now.min.format("%02d")]);
        var dateStr = Lang.format("$1$ $2$ $3$", [now.day_of_week.toUpper().substring(0, 3), now.day.format("%02d"), now.month.toUpper()]);

		dc.drawText(w >> 1, h/9, dateFont, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
		dc.drawText(w >> 1 - 4, h >> 2 + 11, timeFont, timeStr, Gfx.TEXT_JUSTIFY_CENTER); //h/4+6 for dincondensed113.fnt
    }

	function drawBat(dc) {
		
		var bat = Sys.getSystemStats().battery;
		var batStr = bat.format("%d").toString() + "%";

		if (bat < batWarning) {
			dc.setColor(batWarningCol, Gfx.COLOR_TRANSPARENT);
		}

		dc.drawText(w >> 1, -6, batFont, batStr, Gfx.TEXT_JUSTIFY_CENTER);
	}

	//function drawSun() {
		// marks where the sun is and sunset/sunrise 
	//}
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    	on = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    	on = false;
    }

	function getSettings() {
		var app = App.getApp();

		bgCol = app.getProperty("bgCol_prop").toNumber();
		var col = app.getProperty("timeOnCol_prop").toNumber();
		if (col != bgCol) {
			timeOnCol = col;
		}
		
		timeOffCol = app.getProperty("timeOffCol_prop").toNumber();
		btCol = app.getProperty("btCol_prop"); //.toNumber();
		alarmCol = app.getProperty("alarmCol_prop"); //.toNumber();
		batWarningCol = app.getProperty("batWCol_prop"); //.toNumber();
		msgCol = app.getProperty("msgCol_prop"); //.toLong();
		showCount = app.getProperty("countShow_prop"); //.toLong();
		showBat = app.getProperty("batShow_prop"); //.toLong();
		var tmp = app.getProperty("batWarn_prop");
		if (tmp > 0 && tmp < 100) {
			batWarning = tmp;
		}
	}
}
