function padStart(str, len, char) {
  str = String(str);
  while(str.length < len) {
    str = String(char) + str;
  }
  return str;
}

function check404References() {
  var msgElem = document.getElementById("404-references");
  if(!msgElem) return;

  var path = window.location.pathname;
  if(path[0] === "/") path = path.slice(1);
  if(!path) return;

  var pathParts = path.split("/");
  if(pathParts[0].length >= 1) {
    var semesterMatch = pathParts[0].match(/^((sp|su|fa)(\d{2,}))$/);
    if(semesterMatch) {
      msgElem.appendChild(document.createTextNode("Possible archive link: "));

      var refLink = document.createElement("a");
      refLink.href = "https://inst.eecs.berkeley.edu/~cs61c/" + semesterMatch[1] + "/" + pathParts.slice(1).join("/");
      refLink.innerText = refLink.href;
      msgElem.appendChild(refLink);
    }
  }
}

function initCalendar() {
  if(!document.getElementById("calendarContainer")) return;

  var berkeleyTimezoneName = "America/Los_Angeles";
  var hourStart = 0; // in Berkeley timezone
  var hourEnd = 24;

  var currentDTF = Intl.DateTimeFormat("en-US", {
    year: "numeric",
    month: "numeric",
    day: "numeric",
    hour: "numeric",
    minute: "numeric",
    second: "numeric",
    hour12: false,
  });
  var currentTimezoneName = currentDTF.resolvedOptions().timeZone;

  var timezones = [ {
    timezoneName: currentTimezoneName,
    displayLabel: "Local Time",
    tooltip: "Local Time",
  } ];
  if(currentTimezoneName !== berkeleyTimezoneName) {
    timezones.unshift({
      timezoneName: berkeleyTimezoneName,
      displayLabel: "Berkeley",
      tooltip: "Berkeley",
    });
  }

  var calendar = new tui.Calendar("#calendarContainer", {
    usageStatistics: false,
    isReadOnly: true,
    disableClick: true,
    disableDblClick: true,
    useDetailPopup: true,

    defaultView: screen.width >= 576 ? "week" : "day",
    taskView: false,
    timezone: {
      zones: timezones,
    },

    theme: {
      "common.border": "1px solid currentColor",
      "common.backgroundColor": "inherit",
      "common.holiday.color": "inherit",
      "common.saturday.color": "inherit",
      "common.dayname.color": "inherit",
      "common.today.color": "#faa",

      "month.dayname.borderLeft": "1px solid currentColor",

      "month.moreView.border": "1px solid currentColor",
      "month.moreView.backgroundColor": "inherit",

      "week.dayname.borderTop": "1px solid currentColor",
      "week.dayname.borderBottom": "1px solid currentColor",
      "week.today.color": "#faa",
      "week.pastDay.color": "inherit",

      "week.vpanelSplitter.border": "1px solid currentColor",

      "week.daygrid.borderRight": "1px solid currentColor",

      "week.timegridLeft.backgroundColor": "transparent", // bugged
      "week.timegridLeft.borderRight": "2px solid currentColor",
      "week.timegridLeftAdditionalTimezone.backgroundColor": "inherit",

      "week.timegridHorizontalLine.borderBottom": "1px solid currentColor",

      "week.timegrid.borderRight": "1px solid currentColor",

      "week.currentTime.color": "#faa",

      "week.pastTime.color": "inherit",

      "week.futureTime.color": "inherit",

      "week.currentTimeLinePast.border": "1px dashed #faa",
      "week.currentTimeLineBullet.backgroundColor": "#faa",
      "week.currentTimeLineToday.border": "1px solid #faa",
    },
    template: {
      timegridDisplayPrimaryTime: function(time) {
        return padStart(time.hour, 2, "0") + ":" + padStart(time.minutes, 2, "0");
      },
      timegridDisplayTime: function(time) {
        return padStart(time.hour, 2, "0") + ":" + padStart(time.minutes, 2, "0");
      },
    },
    week: {
      hourStart: hourStart,
      hourEnd: hourEnd,
    },
  });

  document.querySelectorAll("#calendarControls a").forEach(function(elem) {
    elem.addEventListener("click", function(e) {
      e.preventDefault();

      if(elem.dataset.action.startsWith("move-")) {
        calendar[elem.dataset.action.slice("move-".length)]();
      } else if(elem.dataset.action.startsWith("change-view-")) {
        calendar.changeView(elem.dataset.action.slice("change-view-".length));
      }
    });
  });

  var googleAPIKey = "AIzaSyBa7KBkLt23PX1HLsy5t_FH_77eNi5svlE";
  var lectureCalendarID = "c_5injdvcueko4k9u68to96p4v04@group.calendar.google.com";
  var ohCalendarID = "c_gdg93mp1225jjubvsflocmajao@group.calendar.google.com";
  var spinnerElem = document.getElementById("calendarSpinner");

  if(spinnerElem) {
    spinnerElem.classList.remove("d-none");
  }
  var loadCount = 2;
  gapi.load("client", function() {
    gapi.client.setApiKey(googleAPIKey);
    gapi.client.load("calendar", "v3", function() {
      loadGoogleCalendar(calendar, {
        calendarID: lectureCalendarID,
        addProps: function(item) {
          return {
            color: ";",
            bgColor: "rgba(221, 136, 59, 0.5)",
          };
        },
      }, function() {
        loadCount--;
        if(loadCount <= 0) {
          spinnerElem.classList.add("d-none");
        }
      });
      loadGoogleCalendar(calendar, {
        calendarID: ohCalendarID,
        addProps: function(item) {
          var bgColor = "rgba(221, 136, 59, 0.5)";
          if(item.summary.indexOf("OH") !== -1 || item.summary.toLowerCase().indexOf("office hour") !== -1) {
            if(item.summary.toLowerCase().indexOf("project") !== -1) {
              bgColor = "rgba(74, 59, 211, 0.5)";
            } else {
              bgColor = "rgba(27, 146, 90, 0.5)";
            }
          } else if(item.summary.toLowerCase().indexOf("discussion") !== -1) {
            bgColor = "rgba(221, 136, 59, 0.5)";
          }
          return {
            color: ";",
            bgColor: bgColor,
          };
        },
      }, function() {
        loadCount--;
        if(loadCount <= 0) {
          spinnerElem.classList.add("d-none");
        }
      });
    });
  });
}

function loadGoogleCalendar(calendar, options, cb) {
  var request = gapi.client.calendar.events.list({
    calendarId : options.calendarID,
    maxResults: 2500,
    orderBy: "startTime",
    singleEvents: true,
  });
  request.execute(function(resp) {
    console.log(resp);

    var events = [];
    for(var i = 0; i < resp.items.length; i++) {
      var item = resp.items[i];

      var event = {
        id: item.id,
        calendarId: options.calendarID,
        title: item.summary,
        body: item.description,
        start: item.start.dateTime,
        end: item.end.dateTime,
        category: "time",
        color: "#fff",
        bgColor: "#084298",
      };
      if(options.addProps) {
        var obj = options.addProps(item);
        for(var key in obj) {
          event[key] = obj[key];
        }
      }
      events.push(event);
    }

    calendar.createSchedules(events);

    cb();
  });
}

function initKaTeXAutoRender() {
  renderMathInElement(document.body, {
    delimiters: [
      { left: "$$", right: "$$", display: false },
    ],
  });
}

function handleStaffFun(elem, isFun) {
  var newSrc = isFun ? elem.dataset.funSrc : elem.dataset.normalSrc;
  if(newSrc && newSrc !== elem.src) {
    elem.src = newSrc;
  }
}

function initToC() {
  if(window.tocbot && document.getElementById("toc-wrapper")) {
    var tocContentWrapper = document.getElementById("toc-content-wrapper");
    var tocWrapper = document.getElementById("toc-wrapper");
    tocbot.init({
      tocSelector: "#" + tocWrapper.id,
      contentSelector: "#" + tocContentWrapper.id,
      headingSelector: "h2, h3, h4",
      hasInnerContainers: true,
      extraListClasses: "nav flex-column",
      listItemClass: "nav-item",
      linkClass: "nav-link",
      activeListItemClass: "active",
      activeLinkClass: "active",
      collapseDepth: 2,
      headingsOffset: 50,
      orderedList: false,
      scrollSmooth: false,
      scrollSmoothDuration: 250,
      scrollSmoothOffset: -50,
      ignoreHiddenElements: true,
    });
  }
}
