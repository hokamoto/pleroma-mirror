var serviceWorkerOption = {"assets":["/static/img/nsfw.74818f9.png","/static/js/manifest.40ebeba9b7a7763cad50.js","/static/js/vendor.fc4a7765732590326559.js","/static/js/app.49e42efc28dea4545516.js","/static/css/app.556f1866faa755419839c651e2f13f3b.css"]};
        
        !function(e){function n(r){if(t[r])return t[r].exports;var o=t[r]={exports:{},id:r,loaded:!1};return e[r].call(o.exports,o,o.exports,n),o.loaded=!0,o.exports}var t={};return n.m=e,n.c=t,n.p="/",n(0)}([function(e,n,t){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function o(){return u.default.getItem("vuex-lz").then(function(e){return e.config.webPushNotifications})}function i(){return clients.matchAll({includeUncontrolled:!0}).then(function(e){return e.filter(function(e){var n=e.type;return"window"===n})})}var a=t(1),u=r(a);self.addEventListener("push",function(e){e.data&&e.waitUntil(o().then(function(n){return n&&i().then(function(n){var t=e.data.json();if(0===n.length)return self.registration.showNotification(t.title,t)})}))}),self.addEventListener("notificationclick",function(e){e.notification.close(),e.waitUntil(i().then(function(e){for(var n=0;n<e.length;n++){var t=e[n];if("/"===t.url&&"focus"in t)return t.focus()}if(clients.openWindow)return clients.openWindow("/")}))})},function(e,n){/*!
	    localForage -- Offline Storage, Improved
	    Version 1.7.3
	    https://localforage.github.io/localForage
	    (c) 2013-2017 Mozilla, Apache License 2.0
	*/
!function(t){if("object"==typeof n&&"undefined"!=typeof e)e.exports=t();else if("function"==typeof define&&define.amd)define([],t);else{var r;r="undefined"!=typeof window?window:"undefined"!=typeof global?global:"undefined"!=typeof self?self:this,r.localforage=t()}}(function(){return function e(n,t,r){function o(a,u){if(!t[a]){if(!n[a]){var c="function"==typeof require&&require;if(!u&&c)return c(a,!0);if(i)return i(a,!0);var f=new Error("Cannot find module '"+a+"'");throw f.code="MODULE_NOT_FOUND",f}var s=t[a]={exports:{}};n[a][0].call(s.exports,function(e){var t=n[a][1][e];return o(t?t:e)},s,s.exports,e,n,t,r)}return t[a].exports}for(var i="function"==typeof require&&require,a=0;a<r.length;a++)o(r[a]);return o}({1:[function(e,n,t){(function(e){"use strict";function t(){s=!0;for(var e,n,t=l.length;t;){for(n=l,l=[],e=-1;++e<t;)n[e]();t=l.length}s=!1}function r(e){1!==l.push(e)||s||o()}var o,i=e.MutationObserver||e.WebKitMutationObserver;if(i){var a=0,u=new i(t),c=e.document.createTextNode("");u.observe(c,{characterData:!0}),o=function(){c.data=a=++a%2}}else if(e.setImmediate||"undefined"==typeof e.MessageChannel)o="document"in e&&"onreadystatechange"in e.document.createElement("script")?function(){var n=e.document.createElement("script");n.onreadystatechange=function(){t(),n.onreadystatechange=null,n.parentNode.removeChild(n),n=null},e.document.documentElement.appendChild(n)}:function(){setTimeout(t,0)};else{var f=new e.MessageChannel;f.port1.onmessage=t,o=function(){f.port2.postMessage(0)}}var s,l=[];n.exports=r}).call(this,"undefined"!=typeof global?global:"undefined"!=typeof self?self:"undefined"!=typeof window?window:{})},{}],2:[function(e,n,t){"use strict";function r(){}function o(e){if("function"!=typeof e)throw new TypeError("resolver must be a function");this.state=m,this.queue=[],this.outcome=void 0,e!==r&&c(this,e)}function i(e,n,t){this.promise=e,"function"==typeof n&&(this.onFulfilled=n,this.callFulfilled=this.otherCallFulfilled),"function"==typeof t&&(this.onRejected=t,this.callRejected=this.otherCallRejected)}function a(e,n,t){h(function(){var r;try{r=n(t)}catch(n){return y.reject(e,n)}r===e?y.reject(e,new TypeError("Cannot resolve promise with itself")):y.resolve(e,r)})}function u(e){var n=e&&e.then;if(e&&("object"==typeof e||"function"==typeof e)&&"function"==typeof n)return function(){n.apply(e,arguments)}}function c(e,n){function t(n){i||(i=!0,y.reject(e,n))}function r(n){i||(i=!0,y.resolve(e,n))}function o(){n(r,t)}var i=!1,a=f(o);"error"===a.status&&t(a.value)}function f(e,n){var t={};try{t.value=e(n),t.status="success"}catch(e){t.status="error",t.value=e}return t}function s(e){return e instanceof this?e:y.resolve(new this(r),e)}function l(e){var n=new this(r);return y.reject(n,e)}function d(e){function n(e,n){function r(e){a[n]=e,++u!==o||i||(i=!0,y.resolve(f,a))}t.resolve(e).then(r,function(e){i||(i=!0,y.reject(f,e))})}var t=this;if("[object Array]"!==Object.prototype.toString.call(e))return this.reject(new TypeError("must be an array"));var o=e.length,i=!1;if(!o)return this.resolve([]);for(var a=new Array(o),u=0,c=-1,f=new this(r);++c<o;)n(e[c],c);return f}function v(e){function n(e){t.resolve(e).then(function(e){i||(i=!0,y.resolve(u,e))},function(e){i||(i=!0,y.reject(u,e))})}var t=this;if("[object Array]"!==Object.prototype.toString.call(e))return this.reject(new TypeError("must be an array"));var o=e.length,i=!1;if(!o)return this.resolve([]);for(var a=-1,u=new this(r);++a<o;)n(e[a]);return u}var h=e(1),y={},p=["REJECTED"],b=["FULFILLED"],m=["PENDING"];n.exports=o,o.prototype.catch=function(e){return this.then(null,e)},o.prototype.then=function(e,n){if("function"!=typeof e&&this.state===b||"function"!=typeof n&&this.state===p)return this;var t=new this.constructor(r);if(this.state!==m){var o=this.state===b?e:n;a(t,o,this.outcome)}else this.queue.push(new i(t,e,n));return t},i.prototype.callFulfilled=function(e){y.resolve(this.promise,e)},i.prototype.otherCallFulfilled=function(e){a(this.promise,this.onFulfilled,e)},i.prototype.callRejected=function(e){y.reject(this.promise,e)},i.prototype.otherCallRejected=function(e){a(this.promise,this.onRejected,e)},y.resolve=function(e,n){var t=f(u,n);if("error"===t.status)return y.reject(e,t.value);var r=t.value;if(r)c(e,r);else{e.state=b,e.outcome=n;for(var o=-1,i=e.queue.length;++o<i;)e.queue[o].callFulfilled(n)}return e},y.reject=function(e,n){e.state=p,e.outcome=n;for(var t=-1,r=e.queue.length;++t<r;)e.queue[t].callRejected(n);return e},o.resolve=s,o.reject=l,o.all=d,o.race=v},{1:1}],3:[function(e,n,t){(function(n){"use strict";"function"!=typeof n.Promise&&(n.Promise=e(2))}).call(this,"undefined"!=typeof global?global:"undefined"!=typeof self?self:"undefined"!=typeof window?window:{})},{2:2}],4:[function(e,n,t){"use strict";function r(e,n){if(!(e instanceof n))throw new TypeError("Cannot call a class as a function")}function o(){try{if("undefined"!=typeof indexedDB)return indexedDB;if("undefined"!=typeof webkitIndexedDB)return webkitIndexedDB;if("undefined"!=typeof mozIndexedDB)return mozIndexedDB;if("undefined"!=typeof OIndexedDB)return OIndexedDB;if("undefined"!=typeof msIndexedDB)return msIndexedDB}catch(e){return}}function i(){try{if(!_e)return!1;var e="undefined"!=typeof openDatabase&&/(Safari|iPhone|iPad|iPod)/.test(navigator.userAgent)&&!/Chrome/.test(navigator.userAgent)&&!/BlackBerry/.test(navigator.platform),n="function"==typeof fetch&&fetch.toString().indexOf("[native code")!==-1;return(!e||n)&&"undefined"!=typeof indexedDB&&"undefined"!=typeof IDBKeyRange}catch(e){return!1}}function a(e,n){e=e||[],n=n||{};try{return new Blob(e,n)}catch(i){if("TypeError"!==i.name)throw i;for(var t="undefined"!=typeof BlobBuilder?BlobBuilder:"undefined"!=typeof MSBlobBuilder?MSBlobBuilder:"undefined"!=typeof MozBlobBuilder?MozBlobBuilder:WebKitBlobBuilder,r=new t,o=0;o<e.length;o+=1)r.append(e[o]);return r.getBlob(n.type)}}function u(e,n){n&&e.then(function(e){n(null,e)},function(e){n(e)})}function c(e,n,t){"function"==typeof n&&e.then(n),"function"==typeof t&&e.catch(t)}function f(e){return"string"!=typeof e&&(console.warn(e+" used as a key, but it is not a string."),e=String(e)),e}function s(){if(arguments.length&&"function"==typeof arguments[arguments.length-1])return arguments[arguments.length-1]}function l(e){for(var n=e.length,t=new ArrayBuffer(n),r=new Uint8Array(t),o=0;o<n;o++)r[o]=e.charCodeAt(o);return t}function d(e){return new we(function(n){var t=e.transaction(Ie,Ae),r=a([""]);t.objectStore(Ie).put(r,"key"),t.onabort=function(e){e.preventDefault(),e.stopPropagation(),n(!1)},t.oncomplete=function(){var e=navigator.userAgent.match(/Chrome\/(\d+)/),t=navigator.userAgent.match(/Edge\//);n(t||!e||parseInt(e[1],10)>=43)}}).catch(function(){return!1})}function v(e){return"boolean"==typeof Se?we.resolve(Se):d(e).then(function(e){return Se=e})}function h(e){var n=Ee[e.name],t={};t.promise=new we(function(e,n){t.resolve=e,t.reject=n}),n.deferredOperations.push(t),n.dbReady?n.dbReady=n.dbReady.then(function(){return t.promise}):n.dbReady=t.promise}function y(e){var n=Ee[e.name],t=n.deferredOperations.pop();if(t)return t.resolve(),t.promise}function p(e,n){var t=Ee[e.name],r=t.deferredOperations.pop();if(r)return r.reject(n),r.promise}function b(e,n){return new we(function(t,r){if(Ee[e.name]=Ee[e.name]||A(),e.db){if(!n)return t(e.db);h(e),e.db.close()}var o=[e.name];n&&o.push(e.version);var i=_e.open.apply(_e,o);n&&(i.onupgradeneeded=function(n){var t=i.result;try{t.createObjectStore(e.storeName),n.oldVersion<=1&&t.createObjectStore(Ie)}catch(t){if("ConstraintError"!==t.name)throw t;console.warn('The database "'+e.name+'" has been upgraded from version '+n.oldVersion+" to version "+n.newVersion+', but the storage "'+e.storeName+'" already exists.')}}),i.onerror=function(e){e.preventDefault(),r(i.error)},i.onsuccess=function(){t(i.result),y(e)}})}function m(e){return b(e,!1)}function g(e){return b(e,!0)}function _(e,n){if(!e.db)return!0;var t=!e.db.objectStoreNames.contains(e.storeName),r=e.version<e.db.version,o=e.version>e.db.version;if(r&&(e.version!==n&&console.warn('The database "'+e.name+"\" can't be downgraded from version "+e.db.version+" to version "+e.version+"."),e.version=e.db.version),o||t){if(t){var i=e.db.version+1;i>e.version&&(e.version=i)}return!0}return!1}function w(e){return new we(function(n,t){var r=new FileReader;r.onerror=t,r.onloadend=function(t){var r=btoa(t.target.result||"");n({__local_forage_encoded_blob:!0,data:r,type:e.type})},r.readAsBinaryString(e)})}function I(e){var n=l(atob(e.data));return a([n],{type:e.type})}function S(e){return e&&e.__local_forage_encoded_blob}function E(e){var n=this,t=n._initReady().then(function(){var e=Ee[n._dbInfo.name];if(e&&e.dbReady)return e.dbReady});return c(t,e,e),t}function N(e){h(e);for(var n=Ee[e.name],t=n.forages,r=0;r<t.length;r++){var o=t[r];o._dbInfo.db&&(o._dbInfo.db.close(),o._dbInfo.db=null)}return e.db=null,m(e).then(function(n){return e.db=n,_(e)?g(e):n}).then(function(r){e.db=n.db=r;for(var o=0;o<t.length;o++)t[o]._dbInfo.db=r}).catch(function(n){throw p(e,n),n})}function j(e,n,t,r){void 0===r&&(r=1);try{var o=e.db.transaction(e.storeName,n);t(null,o)}catch(o){if(r>0&&(!e.db||"InvalidStateError"===o.name||"NotFoundError"===o.name))return we.resolve().then(function(){if(!e.db||"NotFoundError"===o.name&&!e.db.objectStoreNames.contains(e.storeName)&&e.version<=e.db.version)return e.db&&(e.version=e.db.version+1),g(e)}).then(function(){return N(e).then(function(){j(e,n,t,r-1)})}).catch(t);t(o)}}function A(){return{forages:[],db:null,dbReady:null,deferredOperations:[]}}function R(e){function n(){return we.resolve()}var t=this,r={db:null};if(e)for(var o in e)r[o]=e[o];var i=Ee[r.name];i||(i=A(),Ee[r.name]=i),i.forages.push(t),t._initReady||(t._initReady=t.ready,t.ready=E);for(var a=[],u=0;u<i.forages.length;u++){var c=i.forages[u];c!==t&&a.push(c._initReady().catch(n))}var f=i.forages.slice(0);return we.all(a).then(function(){return r.db=i.db,m(r)}).then(function(e){return r.db=e,_(r,t._defaultConfig.version)?g(r):e}).then(function(e){r.db=i.db=e,t._dbInfo=r;for(var n=0;n<f.length;n++){var o=f[n];o!==t&&(o._dbInfo.db=r.db,o._dbInfo.version=r.version)}})}function O(e,n){var t=this;e=f(e);var r=new we(function(n,r){t.ready().then(function(){j(t._dbInfo,je,function(o,i){if(o)return r(o);try{var a=i.objectStore(t._dbInfo.storeName),u=a.get(e);u.onsuccess=function(){var e=u.result;void 0===e&&(e=null),S(e)&&(e=I(e)),n(e)},u.onerror=function(){r(u.error)}}catch(e){r(e)}})}).catch(r)});return u(r,n),r}function x(e,n){var t=this,r=new we(function(n,r){t.ready().then(function(){j(t._dbInfo,je,function(o,i){if(o)return r(o);try{var a=i.objectStore(t._dbInfo.storeName),u=a.openCursor(),c=1;u.onsuccess=function(){var t=u.result;if(t){var r=t.value;S(r)&&(r=I(r));var o=e(r,t.key,c++);void 0!==o?n(o):t.continue()}else n()},u.onerror=function(){r(u.error)}}catch(e){r(e)}})}).catch(r)});return u(r,n),r}function D(e,n,t){var r=this;e=f(e);var o=new we(function(t,o){var i;r.ready().then(function(){return i=r._dbInfo,"[object Blob]"===Ne.call(n)?v(i.db).then(function(e){return e?n:w(n)}):n}).then(function(n){j(r._dbInfo,Ae,function(i,a){if(i)return o(i);try{var u=a.objectStore(r._dbInfo.storeName);null===n&&(n=void 0);var c=u.put(n,e);a.oncomplete=function(){void 0===n&&(n=null),t(n)},a.onabort=a.onerror=function(){var e=c.error?c.error:c.transaction.error;o(e)}}catch(e){o(e)}})}).catch(o)});return u(o,t),o}function B(e,n){var t=this;e=f(e);var r=new we(function(n,r){t.ready().then(function(){j(t._dbInfo,Ae,function(o,i){if(o)return r(o);try{var a=i.objectStore(t._dbInfo.storeName),u=a.delete(e);i.oncomplete=function(){n()},i.onerror=function(){r(u.error)},i.onabort=function(){var e=u.error?u.error:u.transaction.error;r(e)}}catch(e){r(e)}})}).catch(r)});return u(r,n),r}function k(e){var n=this,t=new we(function(e,t){n.ready().then(function(){j(n._dbInfo,Ae,function(r,o){if(r)return t(r);try{var i=o.objectStore(n._dbInfo.storeName),a=i.clear();o.oncomplete=function(){e()},o.onabort=o.onerror=function(){var e=a.error?a.error:a.transaction.error;t(e)}}catch(e){t(e)}})}).catch(t)});return u(t,e),t}function C(e){var n=this,t=new we(function(e,t){n.ready().then(function(){j(n._dbInfo,je,function(r,o){if(r)return t(r);try{var i=o.objectStore(n._dbInfo.storeName),a=i.count();a.onsuccess=function(){e(a.result)},a.onerror=function(){t(a.error)}}catch(e){t(e)}})}).catch(t)});return u(t,e),t}function T(e,n){var t=this,r=new we(function(n,r){return e<0?void n(null):void t.ready().then(function(){j(t._dbInfo,je,function(o,i){if(o)return r(o);try{var a=i.objectStore(t._dbInfo.storeName),u=!1,c=a.openCursor();c.onsuccess=function(){var t=c.result;return t?void(0===e?n(t.key):u?n(t.key):(u=!0,t.advance(e))):void n(null)},c.onerror=function(){r(c.error)}}catch(e){r(e)}})}).catch(r)});return u(r,n),r}function F(e){var n=this,t=new we(function(e,t){n.ready().then(function(){j(n._dbInfo,je,function(r,o){if(r)return t(r);try{var i=o.objectStore(n._dbInfo.storeName),a=i.openCursor(),u=[];a.onsuccess=function(){var n=a.result;return n?(u.push(n.key),void n.continue()):void e(u)},a.onerror=function(){t(a.error)}}catch(e){t(e)}})}).catch(t)});return u(t,e),t}function L(e,n){n=s.apply(this,arguments);var t=this.config();e="function"!=typeof e&&e||{},e.name||(e.name=e.name||t.name,e.storeName=e.storeName||t.storeName);var r,o=this;if(e.name){var i=e.name===t.name&&o._dbInfo.db,a=i?we.resolve(o._dbInfo.db):m(e).then(function(n){var t=Ee[e.name],r=t.forages;t.db=n;for(var o=0;o<r.length;o++)r[o]._dbInfo.db=n;return n});r=e.storeName?a.then(function(n){if(n.objectStoreNames.contains(e.storeName)){var t=n.version+1;h(e);var r=Ee[e.name],o=r.forages;n.close();for(var i=0;i<o.length;i++){var a=o[i];a._dbInfo.db=null,a._dbInfo.version=t}var u=new we(function(n,r){var o=_e.open(e.name,t);o.onerror=function(e){var n=o.result;n.close(),r(e)},o.onupgradeneeded=function(){var n=o.result;n.deleteObjectStore(e.storeName)},o.onsuccess=function(){var e=o.result;e.close(),n(e)}});return u.then(function(e){r.db=e;for(var n=0;n<o.length;n++){var t=o[n];t._dbInfo.db=e,y(t._dbInfo)}}).catch(function(n){throw(p(e,n)||we.resolve()).catch(function(){}),n})}}):a.then(function(n){h(e);var t=Ee[e.name],r=t.forages;n.close();for(var o=0;o<r.length;o++){var i=r[o];i._dbInfo.db=null}var a=new we(function(n,t){var r=_e.deleteDatabase(e.name);r.onerror=r.onblocked=function(e){var n=r.result;n&&n.close(),t(e)},r.onsuccess=function(){var e=r.result;e&&e.close(),n(e)}});return a.then(function(e){t.db=e;for(var n=0;n<r.length;n++){var o=r[n];y(o._dbInfo)}}).catch(function(n){throw(p(e,n)||we.resolve()).catch(function(){}),n})})}else r=we.reject("Invalid arguments");return u(r,n),r}function M(){return"function"==typeof openDatabase}function z(e){var n,t,r,o,i,a=.75*e.length,u=e.length,c=0;"="===e[e.length-1]&&(a--,"="===e[e.length-2]&&a--);var f=new ArrayBuffer(a),s=new Uint8Array(f);for(n=0;n<u;n+=4)t=Oe.indexOf(e[n]),r=Oe.indexOf(e[n+1]),o=Oe.indexOf(e[n+2]),i=Oe.indexOf(e[n+3]),s[c++]=t<<2|r>>4,s[c++]=(15&r)<<4|o>>2,s[c++]=(3&o)<<6|63&i;return f}function P(e){var n,t=new Uint8Array(e),r="";for(n=0;n<t.length;n+=3)r+=Oe[t[n]>>2],r+=Oe[(3&t[n])<<4|t[n+1]>>4],r+=Oe[(15&t[n+1])<<2|t[n+2]>>6],r+=Oe[63&t[n+2]];return t.length%3===2?r=r.substring(0,r.length-1)+"=":t.length%3===1&&(r=r.substring(0,r.length-2)+"=="),r}function U(e,n){var t="";if(e&&(t=Ke.call(e)),e&&("[object ArrayBuffer]"===t||e.buffer&&"[object ArrayBuffer]"===Ke.call(e.buffer))){var r,o=Be;e instanceof ArrayBuffer?(r=e,o+=Ce):(r=e.buffer,"[object Int8Array]"===t?o+=Fe:"[object Uint8Array]"===t?o+=Le:"[object Uint8ClampedArray]"===t?o+=Me:"[object Int16Array]"===t?o+=ze:"[object Uint16Array]"===t?o+=Ue:"[object Int32Array]"===t?o+=Pe:"[object Uint32Array]"===t?o+=qe:"[object Float32Array]"===t?o+=We:"[object Float64Array]"===t?o+=He:n(new Error("Failed to get type for BinaryArray"))),n(o+P(r))}else if("[object Blob]"===t){var i=new FileReader;i.onload=function(){var t=xe+e.type+"~"+P(this.result);n(Be+Te+t)},i.readAsArrayBuffer(e)}else try{n(JSON.stringify(e))}catch(t){console.error("Couldn't convert value into a JSON string: ",e),n(null,t)}}function q(e){if(e.substring(0,ke)!==Be)return JSON.parse(e);var n,t=e.substring(Qe),r=e.substring(ke,Qe);if(r===Te&&De.test(t)){var o=t.match(De);n=o[1],t=t.substring(o[0].length)}var i=z(t);switch(r){case Ce:return i;case Te:return a([i],{type:n});case Fe:return new Int8Array(i);case Le:return new Uint8Array(i);case Me:return new Uint8ClampedArray(i);case ze:return new Int16Array(i);case Ue:return new Uint16Array(i);case Pe:return new Int32Array(i);case qe:return new Uint32Array(i);case We:return new Float32Array(i);case He:return new Float64Array(i);default:throw new Error("Unkown type: "+r)}}function W(e,n,t,r){e.executeSql("CREATE TABLE IF NOT EXISTS "+n.storeName+" (id INTEGER PRIMARY KEY, key unique, value)",[],t,r)}function H(e){var n=this,t={db:null};if(e)for(var r in e)t[r]="string"!=typeof e[r]?e[r].toString():e[r];var o=new we(function(e,r){try{t.db=openDatabase(t.name,String(t.version),t.description,t.size)}catch(e){return r(e)}t.db.transaction(function(o){W(o,t,function(){n._dbInfo=t,e()},function(e,n){r(n)})},r)});return t.serializer=Xe,o}function Q(e,n,t,r,o,i){e.executeSql(t,r,o,function(e,a){a.code===a.SYNTAX_ERR?e.executeSql("SELECT name FROM sqlite_master WHERE type='table' AND name = ?",[n.storeName],function(e,u){u.rows.length?i(e,a):W(e,n,function(){e.executeSql(t,r,o,i)},i)},i):i(e,a)},i)}function K(e,n){var t=this;e=f(e);var r=new we(function(n,r){t.ready().then(function(){var o=t._dbInfo;o.db.transaction(function(t){Q(t,o,"SELECT * FROM "+o.storeName+" WHERE key = ? LIMIT 1",[e],function(e,t){var r=t.rows.length?t.rows.item(0).value:null;r&&(r=o.serializer.deserialize(r)),n(r)},function(e,n){r(n)})})}).catch(r)});return u(r,n),r}function X(e,n){var t=this,r=new we(function(n,r){t.ready().then(function(){var o=t._dbInfo;o.db.transaction(function(t){Q(t,o,"SELECT * FROM "+o.storeName,[],function(t,r){for(var i=r.rows,a=i.length,u=0;u<a;u++){var c=i.item(u),f=c.value;if(f&&(f=o.serializer.deserialize(f)),f=e(f,c.key,u+1),void 0!==f)return void n(f)}n()},function(e,n){r(n)})})}).catch(r)});return u(r,n),r}function G(e,n,t,r){var o=this;e=f(e);var i=new we(function(i,a){o.ready().then(function(){void 0===n&&(n=null);var u=n,c=o._dbInfo;c.serializer.serialize(n,function(n,f){f?a(f):c.db.transaction(function(t){Q(t,c,"INSERT OR REPLACE INTO "+c.storeName+" (key, value) VALUES (?, ?)",[e,n],function(){i(u)},function(e,n){a(n)})},function(n){if(n.code===n.QUOTA_ERR){if(r>0)return void i(G.apply(o,[e,u,t,r-1]));a(n)}})})}).catch(a)});return u(i,t),i}function J(e,n,t){return G.apply(this,[e,n,t,1])}function V(e,n){var t=this;e=f(e);var r=new we(function(n,r){t.ready().then(function(){var o=t._dbInfo;o.db.transaction(function(t){Q(t,o,"DELETE FROM "+o.storeName+" WHERE key = ?",[e],function(){n()},function(e,n){r(n)})})}).catch(r)});return u(r,n),r}function Y(e){var n=this,t=new we(function(e,t){n.ready().then(function(){var r=n._dbInfo;r.db.transaction(function(n){Q(n,r,"DELETE FROM "+r.storeName,[],function(){e()},function(e,n){t(n)})})}).catch(t)});return u(t,e),t}function Z(e){var n=this,t=new we(function(e,t){n.ready().then(function(){var r=n._dbInfo;r.db.transaction(function(n){Q(n,r,"SELECT COUNT(key) as c FROM "+r.storeName,[],function(n,t){var r=t.rows.item(0).c;e(r)},function(e,n){t(n)})})}).catch(t)});return u(t,e),t}function $(e,n){var t=this,r=new we(function(n,r){t.ready().then(function(){var o=t._dbInfo;o.db.transaction(function(t){Q(t,o,"SELECT key FROM "+o.storeName+" WHERE id = ? LIMIT 1",[e+1],function(e,t){var r=t.rows.length?t.rows.item(0).key:null;n(r)},function(e,n){r(n)})})}).catch(r)});return u(r,n),r}function ee(e){var n=this,t=new we(function(e,t){n.ready().then(function(){var r=n._dbInfo;r.db.transaction(function(n){Q(n,r,"SELECT key FROM "+r.storeName,[],function(n,t){for(var r=[],o=0;o<t.rows.length;o++)r.push(t.rows.item(o).key);e(r)},function(e,n){t(n)})})}).catch(t)});return u(t,e),t}function ne(e){return new we(function(n,t){e.transaction(function(r){r.executeSql("SELECT name FROM sqlite_master WHERE type='table' AND name <> '__WebKitDatabaseInfoTable__'",[],function(t,r){for(var o=[],i=0;i<r.rows.length;i++)o.push(r.rows.item(i).name);n({db:e,storeNames:o})},function(e,n){t(n)})},function(e){t(e)})})}function te(e,n){n=s.apply(this,arguments);var t=this.config();e="function"!=typeof e&&e||{},e.name||(e.name=e.name||t.name,e.storeName=e.storeName||t.storeName);var r,o=this;return r=e.name?new we(function(n){var r;r=e.name===t.name?o._dbInfo.db:openDatabase(e.name,"","",0),n(e.storeName?{db:r,storeNames:[e.storeName]}:ne(r))}).then(function(e){return new we(function(n,t){e.db.transaction(function(r){function o(e){return new we(function(n,t){r.executeSql("DROP TABLE IF EXISTS "+e,[],function(){n()},function(e,n){t(n)})})}for(var i=[],a=0,u=e.storeNames.length;a<u;a++)i.push(o(e.storeNames[a]));we.all(i).then(function(){n()}).catch(function(e){t(e)})},function(e){t(e)})})}):we.reject("Invalid arguments"),u(r,n),r}function re(){try{return"undefined"!=typeof localStorage&&"setItem"in localStorage&&!!localStorage.setItem}catch(e){return!1}}function oe(e,n){var t=e.name+"/";return e.storeName!==n.storeName&&(t+=e.storeName+"/"),t}function ie(){var e="_localforage_support_test";try{return localStorage.setItem(e,!0),localStorage.removeItem(e),!1}catch(e){return!0}}function ae(){return!ie()||localStorage.length>0}function ue(e){var n=this,t={};if(e)for(var r in e)t[r]=e[r];return t.keyPrefix=oe(e,n._defaultConfig),ae()?(n._dbInfo=t,t.serializer=Xe,we.resolve()):we.reject()}function ce(e){var n=this,t=n.ready().then(function(){for(var e=n._dbInfo.keyPrefix,t=localStorage.length-1;t>=0;t--){var r=localStorage.key(t);0===r.indexOf(e)&&localStorage.removeItem(r)}});return u(t,e),t}function fe(e,n){var t=this;e=f(e);var r=t.ready().then(function(){var n=t._dbInfo,r=localStorage.getItem(n.keyPrefix+e);return r&&(r=n.serializer.deserialize(r)),r});return u(r,n),r}function se(e,n){var t=this,r=t.ready().then(function(){for(var n=t._dbInfo,r=n.keyPrefix,o=r.length,i=localStorage.length,a=1,u=0;u<i;u++){var c=localStorage.key(u);if(0===c.indexOf(r)){var f=localStorage.getItem(c);if(f&&(f=n.serializer.deserialize(f)),f=e(f,c.substring(o),a++),void 0!==f)return f}}});return u(r,n),r}function le(e,n){var t=this,r=t.ready().then(function(){var n,r=t._dbInfo;try{n=localStorage.key(e)}catch(e){n=null}return n&&(n=n.substring(r.keyPrefix.length)),n});return u(r,n),r}function de(e){var n=this,t=n.ready().then(function(){for(var e=n._dbInfo,t=localStorage.length,r=[],o=0;o<t;o++){var i=localStorage.key(o);0===i.indexOf(e.keyPrefix)&&r.push(i.substring(e.keyPrefix.length))}return r});return u(t,e),t}function ve(e){var n=this,t=n.keys().then(function(e){return e.length});return u(t,e),t}function he(e,n){var t=this;e=f(e);var r=t.ready().then(function(){var n=t._dbInfo;localStorage.removeItem(n.keyPrefix+e)});return u(r,n),r}function ye(e,n,t){var r=this;e=f(e);var o=r.ready().then(function(){void 0===n&&(n=null);var t=n;return new we(function(o,i){var a=r._dbInfo;a.serializer.serialize(n,function(n,r){if(r)i(r);else try{localStorage.setItem(a.keyPrefix+e,n),o(t)}catch(e){"QuotaExceededError"!==e.name&&"NS_ERROR_DOM_QUOTA_REACHED"!==e.name||i(e),i(e)}})})});return u(o,t),o}function pe(e,n){if(n=s.apply(this,arguments),e="function"!=typeof e&&e||{},!e.name){var t=this.config();e.name=e.name||t.name,e.storeName=e.storeName||t.storeName}var r,o=this;return r=e.name?new we(function(n){n(e.storeName?oe(e,o._defaultConfig):e.name+"/")}).then(function(e){for(var n=localStorage.length-1;n>=0;n--){var t=localStorage.key(n);0===t.indexOf(e)&&localStorage.removeItem(t)}}):we.reject("Invalid arguments"),u(r,n),r}function be(e,n){e[n]=function(){var t=arguments;return e.ready().then(function(){return e[n].apply(e,t)})}}function me(){for(var e=1;e<arguments.length;e++){var n=arguments[e];if(n)for(var t in n)n.hasOwnProperty(t)&&(Ze(n[t])?arguments[0][t]=n[t].slice():arguments[0][t]=n[t])}return arguments[0]}var ge="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(e){return typeof e}:function(e){return e&&"function"==typeof Symbol&&e.constructor===Symbol&&e!==Symbol.prototype?"symbol":typeof e},_e=o();"undefined"==typeof Promise&&e(3);var we=Promise,Ie="local-forage-detect-blob-support",Se=void 0,Ee={},Ne=Object.prototype.toString,je="readonly",Ae="readwrite",Re={_driver:"asyncStorage",_initStorage:R,_support:i(),iterate:x,getItem:O,setItem:D,removeItem:B,clear:k,length:C,key:T,keys:F,dropInstance:L},Oe="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",xe="~~local_forage_type~",De=/^~~local_forage_type~([^~]+)~/,Be="__lfsc__:",ke=Be.length,Ce="arbf",Te="blob",Fe="si08",Le="ui08",Me="uic8",ze="si16",Pe="si32",Ue="ur16",qe="ui32",We="fl32",He="fl64",Qe=ke+Ce.length,Ke=Object.prototype.toString,Xe={serialize:U,deserialize:q,stringToBuffer:z,bufferToString:P},Ge={_driver:"webSQLStorage",_initStorage:H,_support:M(),iterate:X,getItem:K,setItem:J,removeItem:V,clear:Y,length:Z,key:$,keys:ee,dropInstance:te},Je={_driver:"localStorageWrapper",_initStorage:ue,_support:re(),iterate:se,getItem:fe,setItem:ye,removeItem:he,clear:ce,length:ve,key:le,keys:de,dropInstance:pe},Ve=function(e,n){return e===n||"number"==typeof e&&"number"==typeof n&&isNaN(e)&&isNaN(n)},Ye=function(e,n){for(var t=e.length,r=0;r<t;){if(Ve(e[r],n))return!0;r++}return!1},Ze=Array.isArray||function(e){return"[object Array]"===Object.prototype.toString.call(e)},$e={},en={},nn={INDEXEDDB:Re,WEBSQL:Ge,LOCALSTORAGE:Je},tn=[nn.INDEXEDDB._driver,nn.WEBSQL._driver,nn.LOCALSTORAGE._driver],rn=["dropInstance"],on=["clear","getItem","iterate","key","keys","length","removeItem","setItem"].concat(rn),an={description:"",driver:tn.slice(),name:"localforage",size:4980736,storeName:"keyvaluepairs",version:1},un=function(){function e(n){r(this,e);for(var t in nn)if(nn.hasOwnProperty(t)){var o=nn[t],i=o._driver;this[t]=i,$e[i]||this.defineDriver(o)}this._defaultConfig=me({},an),this._config=me({},this._defaultConfig,n),this._driverSet=null,this._initDriver=null,this._ready=!1,this._dbInfo=null,this._wrapLibraryMethodsWithReady(),this.setDriver(this._config.driver).catch(function(){})}return e.prototype.config=function(e){if("object"===("undefined"==typeof e?"undefined":ge(e))){if(this._ready)return new Error("Can't call config() after localforage has been used.");for(var n in e){if("storeName"===n&&(e[n]=e[n].replace(/\W/g,"_")),"version"===n&&"number"!=typeof e[n])return new Error("Database version must be a number.");this._config[n]=e[n]}return!("driver"in e&&e.driver)||this.setDriver(this._config.driver)}return"string"==typeof e?this._config[e]:this._config},e.prototype.defineDriver=function(e,n,t){var r=new we(function(n,t){try{var r=e._driver,o=new Error("Custom driver not compliant; see https://mozilla.github.io/localForage/#definedriver");if(!e._driver)return void t(o);for(var i=on.concat("_initStorage"),a=0,c=i.length;a<c;a++){var f=i[a],s=!Ye(rn,f);if((s||e[f])&&"function"!=typeof e[f])return void t(o)}var l=function(){for(var n=function(e){return function(){var n=new Error("Method "+e+" is not implemented by the current driver"),t=we.reject(n);return u(t,arguments[arguments.length-1]),t}},t=0,r=rn.length;t<r;t++){var o=rn[t];e[o]||(e[o]=n(o))}};l();var d=function(t){$e[r]&&console.info("Redefining LocalForage driver: "+r),$e[r]=e,en[r]=t,n()};"_support"in e?e._support&&"function"==typeof e._support?e._support().then(d,t):d(!!e._support):d(!0)}catch(e){t(e)}});return c(r,n,t),r},e.prototype.driver=function(){return this._driver||null},e.prototype.getDriver=function(e,n,t){var r=$e[e]?we.resolve($e[e]):we.reject(new Error("Driver not found."));return c(r,n,t),r},e.prototype.getSerializer=function(e){var n=we.resolve(Xe);return c(n,e),n},e.prototype.ready=function(e){var n=this,t=n._driverSet.then(function(){return null===n._ready&&(n._ready=n._initDriver()),n._ready});return c(t,e,e),t},e.prototype.setDriver=function(e,n,t){function r(){a._config.driver=a.driver()}function o(e){return a._extend(e),r(),a._ready=a._initStorage(a._config),a._ready}function i(e){return function(){function n(){for(;t<e.length;){var i=e[t];return t++,a._dbInfo=null,a._ready=null,a.getDriver(i).then(o).catch(n)}r();var u=new Error("No available storage method found.");return a._driverSet=we.reject(u),a._driverSet}var t=0;return n()}}var a=this;Ze(e)||(e=[e]);var u=this._getSupportedDrivers(e),f=null!==this._driverSet?this._driverSet.catch(function(){return we.resolve()}):we.resolve();return this._driverSet=f.then(function(){var e=u[0];return a._dbInfo=null,a._ready=null,a.getDriver(e).then(function(e){a._driver=e._driver,r(),a._wrapLibraryMethodsWithReady(),a._initDriver=i(u)})}).catch(function(){r();var e=new Error("No available storage method found.");return a._driverSet=we.reject(e),a._driverSet}),c(this._driverSet,n,t),this._driverSet},e.prototype.supports=function(e){return!!en[e]},e.prototype._extend=function(e){me(this,e)},e.prototype._getSupportedDrivers=function(e){for(var n=[],t=0,r=e.length;t<r;t++){var o=e[t];this.supports(o)&&n.push(o)}return n},e.prototype._wrapLibraryMethodsWithReady=function(){for(var e=0,n=on.length;e<n;e++)be(this,on[e])},e.prototype.createInstance=function(n){return new e(n)},e}(),cn=new un;n.exports=cn},{3:3}]},{},[4])(4)})}]);
//# sourceMappingURL=sw-pleroma.js.map