(window.webpackJsonp=window.webpackJsonp||[]).push([[61],{718:function(e,t,n){"use strict";n.r(t);var i,o,s=n(1),a=n(6),c=n(0),l=n(2),r=n(3),u=n.n(r),d=n(20),h=n(32),m=n(626),b=n(430),g=n(428),p=n(205),f=n(7),O=n(911),j=n(912),_=Object(f.f)({filter_regex:{id:"home.column_settings.filter_regex",defaultMessage:"Filter out by regular expressions"},settings:{id:"home.settings",defaultMessage:"Column settings"}}),v=Object(f.g)(i=function(e){function t(){return e.apply(this,arguments)||this}return Object(a.a)(t,e),t.prototype.render=function(){var e=this.props,t=e.settings,n=e.onChange,i=e.intl;return Object(s.a)("div",{},void 0,Object(s.a)("span",{className:"column-settings__section"},void 0,Object(s.a)(f.b,{id:"home.column_settings.basic",defaultMessage:"Basic"})),Object(s.a)("div",{className:"column-settings__row"},void 0,Object(s.a)(O.a,{prefix:"home_timeline",settings:t,settingPath:["shows","reblog"],onChange:n,label:Object(s.a)(f.b,{id:"home.column_settings.show_reblogs",defaultMessage:"Show boosts"})})),Object(s.a)("div",{className:"column-settings__row"},void 0,Object(s.a)(O.a,{prefix:"home_timeline",settings:t,settingPath:["shows","reply"],onChange:n,label:Object(s.a)(f.b,{id:"home.column_settings.show_replies",defaultMessage:"Show replies"})})),Object(s.a)("div",{className:"column-settings__row"},void 0,Object(s.a)(O.a,{prefix:"home_timeline",settings:t,settingPath:["shows","direct"],onChange:n,label:Object(s.a)(f.b,{id:"home.column_settings.show_direct",defaultMessage:"Show DMs"})})),Object(s.a)("span",{className:"column-settings__section"},void 0,Object(s.a)(f.b,{id:"home.column_settings.advanced",defaultMessage:"Advanced"})),Object(s.a)("div",{className:"column-settings__row"},void 0,Object(s.a)(j.a,{prefix:"home_timeline",settings:t,settingPath:["regex","body"],onChange:n,label:i.formatMessage(_.filter_regex)})))},t}(u.a.PureComponent))||i,M=n(84),w=Object(d.connect)(function(e){return{settings:e.getIn(["settings","home"])}},function(n){return{onChange:function(e,t){n(Object(M.c)(["home"].concat(e),t))},onSave:function(){n(Object(M.d)())}}})(v),P=n(388);n.d(t,"default",function(){return y});var C=Object(f.f)({title:{id:"column.home",defaultMessage:"Home"}}),y=Object(d.connect)(function(e){return{hasUnread:0<e.getIn(["timelines","home","unread"]),isPartial:null===e.getIn(["timelines","home","items",0],null)}})(o=Object(f.g)(o=function(o){function e(){for(var i,e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return i=o.call.apply(o,[this].concat(t))||this,Object(l.a)(Object(c.a)(Object(c.a)(i)),"handlePin",function(){var e=i.props,t=e.columnId,n=e.dispatch;n(t?Object(p.h)(t):Object(p.e)("HOME",{}))}),Object(l.a)(Object(c.a)(Object(c.a)(i)),"handleMove",function(e){var t=i.props,n=t.columnId;(0,t.dispatch)(Object(p.g)(n,e))}),Object(l.a)(Object(c.a)(Object(c.a)(i)),"handleHeaderClick",function(){i.column.scrollTop()}),Object(l.a)(Object(c.a)(Object(c.a)(i)),"setRef",function(e){i.column=e}),Object(l.a)(Object(c.a)(Object(c.a)(i)),"handleLoadMore",function(e){i.props.dispatch(Object(h.r)({maxId:e}))}),i}Object(a.a)(e,o);var t=e.prototype;return t.componentDidMount=function(){this._checkIfReloadNeeded(!1,this.props.isPartial)},t.componentDidUpdate=function(e){this._checkIfReloadNeeded(e.isPartial,this.props.isPartial)},t.componentWillUnmount=function(){this._stopPolling()},t._checkIfReloadNeeded=function(e,t){var n=this.props.dispatch;e!==t&&(!e&&t?this.polling=setInterval(function(){n(Object(h.r)())},3e3):e&&!t&&this._stopPolling())},t._stopPolling=function(){this.polling&&(clearInterval(this.polling),this.polling=null)},t.render=function(){var e=this.props,t=e.intl,n=e.hasUnread,i=e.columnId,o=e.multiColumn,a=!!i;return u.a.createElement(b.a,{ref:this.setRef,name:"home",label:t.formatMessage(C.title)},Object(s.a)(g.a,{icon:"home",active:n,title:t.formatMessage(C.title),onPin:this.handlePin,onMove:this.handleMove,onClick:this.handleHeaderClick,pinned:a,multiColumn:o},void 0,Object(s.a)(w,{})),Object(s.a)(m.a,{trackScroll:!a,scrollKey:"home_timeline-"+i,onLoadMore:this.handleLoadMore,timelineId:"home",emptyMessage:Object(s.a)(f.b,{id:"empty_column.home",defaultMessage:"Your home timeline is empty! Visit {public} or use search to get started and meet other users.",values:{public:Object(s.a)(P.a,{to:"/timelines/public"},void 0,Object(s.a)(f.b,{id:"empty_column.home.public_timeline",defaultMessage:"the public timeline"}))}})}))},e}(u.a.PureComponent))||o)||o}}]);
//# sourceMappingURL=home_timeline.js.map