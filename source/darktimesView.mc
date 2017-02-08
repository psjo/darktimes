using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Application as App;
using Toybox.Math as Math;

class darktimesView extends Ui.WatchFace {
    var loadSettings = true;
    var countFont = Gfx.FONT_NUMBER_MEDIUM;
    var dateFont = Gfx.FONT_SYSTEM_LARGE;
    var timeFont;
    var batFont = Gfx.FONT_SYSTEM_LARGE;
    var w, h; // width, height
    var timedOn;
    var timedOff;
    var on = true;
    var is24 = true;
    var showCount;
    var showBat;
    var showDate;
    var showAnalog;
    var timed = false;
    var batWarning = 15;
    var batWarningCol; // = Gfx.COLOR_PINK;
    var timeOnCol = Gfx.COLOR_WHITE;
    var timeOffCol; // = Gfx.COLOR_BLACK;
    var timedCol; // = Gfx.COLOR_DK_GRAY;
    var btCol; // = Gfx.COLOR_DK_GRAY;
    var alarmCol; // = Gfx.COLOR_LT_GRAY;
    var bgCol; //Gfx.COLOR_BLACK;
    var msgCol; //Gfx.COLOR_WHITE;
    var colonPos; // 0=bottom, 46=top
    var min = []; // minute hand
    var hour = []; // hour hand
    var sqrt3d2 = Math.sqrt(3) / 2;
    var pit2 = Math.PI * 2;
    var pid6 = Math.PI / 6;
    var hl = 1; // 1 is short, 2, 3=medium, 4=center, 5=extra long


    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        w = dc.getWidth();
        h = dc.getHeight();
        timeFont = Ui.loadResource(Rez.Fonts.id_theFont);
    }

    function onShow() {
    }

    function onUpdate(dc) {
        if (loadSettings) {
            getSettings();
            loadSettings = false;
        }
        drawBG(dc);

        // draw time or not
        if (on) {
            drawMsg(dc);
            dc.setColor(timeOnCol, Gfx.COLOR_TRANSPARENT);
            drawTime(dc);
            drawBat(dc);
        } else if (timeOffCol != bgCol) {
            drawMsg(dc);
            dc.setColor(timeOffCol, Gfx.COLOR_TRANSPARENT);
            drawTime(dc);
            if (showBat) {
                drawBat(dc);
            }
        } else if (timed) {
            var h = Sys.getClockTime().hour;
            if ((timedOn > timedOff and (h >= timedOn or h < timedOff)) or (timedOn < timedOff and (h >= timedOn and h < timedOff))) {
                drawMsg(dc);
                dc.setColor(timedCol, Gfx.COLOR_TRANSPARENT);
                drawTime(dc);
                if (showBat) {
                    drawBat(dc);
                }
            } else if (showAnalog) {
                drawAnalog(dc);
            } else {
                drawMsg(dc);
            }
        } else if (showAnalog){
            drawAnalog(dc);
        } else {
            drawMsg(dc);
        }
    }

    function drawMsg(dc) {

        var settings = Sys.getDeviceSettings();
        var conn = settings.phoneConnected;

        if (conn) {

            var msgs = settings.notificationCount;
            var alarms = settings.alarmCount;
            var pad = 0; // fenix...
            if (h ^ w) { // fr230...
                pad = 4;
            }

            if (msgs > 0) {
                dc.setColor(msgCol, Gfx.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle((w >> 1) + 2, 3*h >> 2 + pad, (w >> 1) - 22, h >> 2, 8);
                if (on && showCount) {
                    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
                    dc.drawText((w >> 1) + (w >> 3), h/3 << 1 + 12, countFont, msgs.format("%d"), Gfx.TEXT_JUSTIFY_CENTER);
                }
            }

            if (alarms > 0){
                dc.setColor(alarmCol, Gfx.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle( w >> 2, 3*h >> 2 + pad, (w >> 2), h >> 2, 8);
                if (on && showCount) {
                    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
                    dc.drawText((w >> 1) - (w >> 3), h/3 << 1 + 12, countFont, alarms.format("%d"), Gfx.TEXT_JUSTIFY_CENTER);
                }
            }

            dc.setColor(btCol, Gfx.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle( 19, 3*h >> 2 + pad, (w >> 2) - 22, h >> 2, 8);
        }
    }

    function drawBG(dc) {
        dc.setColor(0, bgCol);
        dc.clear();
    }

    function drawTime(dc) {
        var now = Calendar.info(Time.now(), Time.FORMAT_MEDIUM);
        var H = now.hour;
        var M = now.min;
        var padHx = 0; //fenix pad
        var padMx = 0;
        var pady = 0;
        var padDate = 0;

        if (!is24 and H > 12) {
            H -= 12;
        }
        if (h ^ w) { // fr230...
            padHx = 1;
            padMx = -2;
            pady = -10;
            padDate = -3;
        }
        if (on or showDate) {
            var dateStr = Lang.format("$1$ $2$ $3$", [now.day_of_week.toUpper().substring(0, 3), now.day.format("%02d"), now.month.toUpper()]);
            dc.drawText(w >> 1, h/9 + padDate, dateFont, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
        }
        dc.drawText(w >> 1 - 59 + padHx, h >> 2 + 11 + pady, timeFont, H.format("%02d"), Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(w >> 1 - 4, h >> 2 + 11 + pady - colonPos, timeFont, ":", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(w >> 1 + 52 + padMx, h >> 2 + 11 + pady, timeFont, M.format("%02d"), Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawBat(dc) {
        var bat = Sys.getSystemStats().battery;
        var batStr = bat.format("%d") + "%";

        if (bat < batWarning) {
            dc.setColor(batWarningCol, Gfx.COLOR_TRANSPARENT);
        }
        dc.drawText(w >> 1, -5, batFont, batStr, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawAnalog(dc) {
        var now = Sys.getClockTime();
        var m = now.min;
        var hr = pid6*(now.hour % 12 + m/60.0);
        m = pid6*m/5.0;
        var mina = new [2];
        dc.setPenWidth(4);

        // hour
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
        //mina[0] = [h >> 1 + hour[0][0]*Math.sin(hour[0][1] + hr), h >> 1 - hour[0][0]*Math.cos(hour[0][1] + hr)];
        //mina[1] = [h >> 1 + hour[hl][0]*Math.sin(hour[hl][1] + hr), h >> 1 - hour[hl][0]*Math.cos(hour[hl][1] + hr)];
        mina[0] = [h >> 1 + hour[0][0]*Math.sin(hr), h >> 1 - hour[0][0]*Math.cos(hr)];
        mina[1] = [h >> 1 + hour[hl][0]*Math.sin(hr), h >> 1 - hour[hl][0]*Math.cos(hr)];
        dc.drawLine(mina[0][0]+(w-h)/2, mina[0][1], mina[1][0]+(w-h)/2, mina[1][1]);

        // minute
        if (Sys.getDeviceSettings().notificationCount) {
            dc.setColor(~Gfx.COLOR_RED, -1);
            //dc.setColor(Gfx.COLOR_GREEN, -1);
        } else {
            dc.setColor(Gfx.COLOR_RED, -1);
        }
        //mina[0] = [h >> 1 + min[0][0]*Math.sin(min[0][1] + m), h >> 1 - min[0][0]*Math.cos(min[0][1] + m)];
        //mina[1] = [h >> 1 + min[hl][0]*Math.sin(min[hl][1] + m), h >> 1 - min[hl][0]*Math.cos(min[hl][1] + m)];
        mina[0] = [h >> 1 + min[0][0]*Math.sin( m ), h >> 1 - min[0][0]*Math.cos( m )];
        mina[1] = [h >> 1 + min[hl][0]*Math.sin( m ), h >> 1 - min[hl][0]*Math.cos( m )];
        dc.drawLine(mina[0][0]+(w - h)/2, mina[0][1], mina[1][0]+(w - h)/2, mina[1][1]);
    }

    function onHide() {
    }

    function onExitSleep() {
        on = true;
    }

    function onEnterSleep() {
        on = false;
    }

    function getSettings() {
        var settings = Sys.getDeviceSettings();
        is24 = settings.is24Hour;
        // min, hour in cyl.coords
        min = [ [ h >> 1 - 6, 0 ],
                [ h >> 1 - 24, 0 ],
                [ h >> 2, 0 ],
                [ h >> 3, 0 ],
                [ 0, 0 ],
                [ -h >> 3, 0 ] ];
        //min = toCyl(min, 6);
        hour = [ [ h >> 1 - 24, 0 ],
                [ h >> 1 - 36, 0 ],
                [ h >> 2 - 14, 0 ],
                [  h >> 3 - 14, 0 ],
                [ 0, 0 ],
                [ -h >> 4, 0 ] ];
        //hour = toCyl(hour, 6);

        var app = App.getApp();

        bgCol = app.getProperty("bgCol_prop");
        timeOnCol = app.getProperty("timeOnCol_prop");

        timeOffCol = app.getProperty("timeOffCol_prop");
        btCol = app.getProperty("btCol_prop");
        alarmCol = app.getProperty("alarmCol_prop");
        batWarningCol = app.getProperty("batWCol_prop");
        msgCol = app.getProperty("msgCol_prop");
        showCount = app.getProperty("countShow_prop");
        showBat = app.getProperty("batShow_prop");
        showDate = app.getProperty("dateShow_prop");
        batWarning = app.getProperty("batWarn_prop");
        timed = app.getProperty("timed_prop");
        timedCol = app.getProperty("timedCol_prop");
        timedOn = app.getProperty("timedOn_prop");
        timedOff = app.getProperty("timedOff_prop");
        colonPos = app.getProperty("colonPos_prop");
        showAnalog = app.getProperty("analogShow_prop");
        hl = app.getProperty("hl_prop");
    }

    /* preparation for more advanced hands
    function toCyl(pos, len) {
        var r;
        var a;
        for (var i = 0; i < len; i += 1) {
            r = Math.sqrt(Math.pow(pos[i][0], 2) + Math.pow(pos[i][1], 2));
            a = Math.acos(pos[i][1]/r);
            if (pos[i][0] < 0) {
                pos[i] = [r, -a];
            } else {
                pos[i] = [r, a];
            }
        }
        return pos;
    }
    */
}
