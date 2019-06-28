(window.webpackJsonp=window.webpackJsonp||[]).push([[62],{708:function(e,t,n){"use strict";n.r(t);var i,o,a=n(0),s=n(2),c=n(6),l=n(1),r=n(3),u=n.n(r),d=n(21),h=n(34),m=n(900),b=n(632),g=n(627),p=n(221),f=n(7),O=n(925),j=n(926),_=Object(f.f)({filter_regex:{id:"home.column_settings.filter_regex",defaultMessage:"Filter out by regular expressions"},settings:{id:"home.settings",defaultMessage:"Column settings"}}),v=Object(f.g)(i=function(e){function t(){return e.apply(this,arguments)||this}return Object(c.a)(t,e),t.prototype.render=function(){var e=this.props,t=e.settings,n=e.onChange,i=e.intl;return Object(a.a)("div",{},void 0,Object(a.a)("span",{className:"column-settings__section"},void 0,Object(a.a)(f.b,{id:"home.column_settings.basic",defaultMessage:"Basic"})),Object(a.a)("div",{className:"column-settings__row"},void 0,Object(a.a)(O.a,{prefix:"home_timeline",settings:t,settingPath:["shows","reblog"],onChange:n,label:Object(a.a)(f.b,{id:"home.column_settings.show_reblogs",defaultMessage:"Show boosts"})})),Object(a.a)("div",{className:"column-settings__row"},void 0,Object(a.a)(O.a,{prefix:"home_timeline",settings:t,settingPath:["shows","reply"],onChange:n,label:Object(a.a)(f.b,{id:"home.column_settings.show_replies",defaultMessage:"Show replies"})})),Object(a.a)("div",{className:"column-settings__row"},void 0,Object(a.a)(O.a,{prefix:"home_timeline",settings:t,settingPath:["shows","direct"],onChange:n,label:Object(a.a)(f.b,{id:"home.column_settings.show_direct",defaultMessage:"Show DMs"})})),Object(a.a)("span",{className:"column-settings__section"},void 0,Object(a.a)(f.b,{id:"home.column_settings.advanced",defaultMessage:"Advanced"})),Object(a.a)("div",{className:"column-settings__row"},void 0,Object(a.a)(j.a,{prefix:"home_timeline",settings:t,settingPath:["regex","body"],onChange:n,label:i.formatMessage(_.filter_regex)})))},t}(u.a.PureComponent))||i,M=n(69),w=Object(d.connect)(function(e){return{settings:e.getIn(["settings","home"])}},function(n){return{onChange:function(e,t){n(Object(M.c)(["home"].concat(e),t))},onSave:function(){n(Object(M.d)())}}})(v),P=n(358);n.d(t,"default",function(){return y});var C=Object(f.f)({title:{id:"column.home",defaultMessage:"Home"}}),y=Object(d.connect)(function(e){return{hasUnread:0<e.getIn(["timelines","home","unread"]),isPartial:e.getIn(["timelines","home","isPartial"])}})(o=Object(f.g)(o=function(o){function e(){for(var i,e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return i=o.call.apply(o,[this].concat(t))||this,Object(l.a)(Object(s.a)(i),"handlePin",function(){var e=i.props,t=e.columnId,n=e.dispatch;n(t?Object(p.h)(t):Object(p.e)("HOME",{}))}),Object(l.a)(Object(s.a)(i),"handleMove",function(e){var t=i.props,n=t.columnId;(0,t.dispatch)(Object(p.g)(n,e))}),Object(l.a)(Object(s.a)(i),"handleHeaderClick",function(){i.column.scrollTop()}),Object(l.a)(Object(s.a)(i),"setRef",function(e){i.column=e}),Object(l.a)(Object(s.a)(i),"handleLoadMore",function(e){i.props.dispatch(Object(h.t)({maxId:e}))}),i}Object(c.a)(e,o);var t=e.prototype;return t.componentDidMount=function(){this._checkIfReloadNeeded(!1,this.props.isPartial)},t.componentDidUpdate=function(e){this._checkIfReloadNeeded(e.isPartial,this.props.isPartial)},t.componentWillUnmount=function(){this._stopPolling()},t._checkIfReloadNeeded=function(e,t){var n=this.props.dispatch;e!==t&&(!e&&t?this.polling=setInterval(function(){n(Object(h.t)())},3e3):e&&!t&&this._stopPolling())},t._stopPolling=function(){this.polling&&(clearInterval(this.polling),this.polling=null)},t.render=function(){var e=this.props,t=e.intl,n=e.hasUnread,i=e.columnId,o=e.multiColumn,s=!!i;return u.a.createElement(b.a,{ref:this.setRef,name:"home",label:t.formatMessage(C.title)},Object(a.a)(g.a,{icon:"home",active:n,title:t.formatMessage(C.title),onPin:this.handlePin,onMove:this.handleMove,onClick:this.handleHeaderClick,pinned:s,multiColumn:o},void 0,Object(a.a)(w,{})),Object(a.a)(m.a,{trackScroll:!s,scrollKey:"home_timeline-"+i,onLoadMore:this.handleLoadMore,timelineId:"home",emptyMessage:Object(a.a)(f.b,{id:"empty_column.home",defaultMessage:"Your home timeline is empty! Visit {public} or use search to get started and meet other users.",values:{public:Object(a.a)(P.a,{to:"/timelines/public"},void 0,Object(a.a)(f.b,{id:"empty_column.home.public_timeline",defaultMessage:"the public timeline"}))}})}))},e}(u.a.PureComponent))||o)||o}}]);
//# sourceMappingURL=home_timeline.js.map