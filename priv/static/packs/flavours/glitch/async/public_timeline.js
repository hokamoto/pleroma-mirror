(window.webpackJsonp=window.webpackJsonp||[]).push([[73],{719:function(e,t,n){"use strict";n.r(t);var o,i,a,l=n(0),c=n(3),r=n(7),d=n(1),s=n(2),u=n.n(s),p=n(24),b=n(6),h=n(5),m=n.n(h),f=n(894),j=n(630),O=n(626),M=n(34),g=n(222),y=n(965),v=n(68),I=Object(p.connect)(function(e,t){var n=t.columnId,o=e.getIn(["settings","columns"]),i=o.findIndex(function(e){return e.get("uuid")===n});return{settings:n&&0<=i?o.get(i).get("params"):e.getIn(["settings","public"])}},function(n,e){var o=e.columnId;return{onChange:function(e,t){n(o?Object(g.f)(o,e,t):Object(v.c)(["public"].concat(e),t))}}})(y.a),w=n(634);n.d(t,"default",function(){return k});var C=Object(b.f)({title:{id:"column.public",defaultMessage:"Federated timeline"}}),k=Object(p.connect)(function(e,t){var n=t.onlyMedia,o=t.columnId,i=o,a=e.getIn(["settings","columns"]),c=a.findIndex(function(e){return e.get("uuid")===i});return{hasUnread:0<e.getIn(["timelines","public"+(n?":media":""),"unread"]),onlyMedia:o&&0<=c?a.get(c).getIn(["params","other","onlyMedia"]):e.getIn(["settings","public","other","onlyMedia"])}})(o=Object(b.g)((a=i=function(o){function e(){for(var i,e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return i=o.call.apply(o,[this].concat(t))||this,Object(d.a)(Object(c.a)(i),"handlePin",function(){var e=i.props,t=e.columnId,n=e.dispatch,o=e.onlyMedia;n(t?Object(g.h)(t):Object(g.e)("PUBLIC",{other:{onlyMedia:o}}))}),Object(d.a)(Object(c.a)(i),"handleMove",function(e){var t=i.props,n=t.columnId;(0,t.dispatch)(Object(g.g)(n,e))}),Object(d.a)(Object(c.a)(i),"handleHeaderClick",function(){i.column.scrollTop()}),Object(d.a)(Object(c.a)(i),"setRef",function(e){i.column=e}),Object(d.a)(Object(c.a)(i),"handleLoadMore",function(e){var t=i.props,n=t.dispatch,o=t.onlyMedia;n(Object(M.v)({maxId:e,onlyMedia:o}))}),Object(d.a)(Object(c.a)(i),"shouldUpdateScroll",function(e,t){var n=t.location;return!(n.state&&n.state.mastodonModalOpen)}),i}Object(r.a)(e,o);var t=e.prototype;return t.componentDidMount=function(){var e=this.props,t=e.dispatch,n=e.onlyMedia;t(Object(M.v)({onlyMedia:n})),this.disconnect=t(Object(w.e)({onlyMedia:n}))},t.componentDidUpdate=function(e){if(e.onlyMedia!==this.props.onlyMedia){var t=this.props,n=t.dispatch,o=t.onlyMedia;this.disconnect(),n(Object(M.v)({onlyMedia:o})),this.disconnect=n(Object(w.e)({onlyMedia:o}))}},t.componentWillUnmount=function(){this.disconnect&&(this.disconnect(),this.disconnect=null)},t.render=function(){var e=this.props,t=e.intl,n=e.columnId,o=e.hasUnread,i=e.multiColumn,a=e.onlyMedia,c=!!n;return u.a.createElement(j.a,{ref:this.setRef,name:"federated",label:t.formatMessage(C.title)},Object(l.a)(O.a,{icon:"globe",active:o,title:t.formatMessage(C.title),onPin:this.handlePin,onMove:this.handleMove,onClick:this.handleHeaderClick,pinned:c,multiColumn:i},void 0,Object(l.a)(I,{columnId:n})),Object(l.a)(f.a,{timelineId:"public"+(a?":media":""),onLoadMore:this.handleLoadMore,trackScroll:!c,scrollKey:"public_timeline-"+n,emptyMessage:Object(l.a)(b.b,{id:"empty_column.public",defaultMessage:"There is nothing here! Write something publicly, or manually follow users from other servers to fill it up"})}))},e}(u.a.PureComponent),Object(d.a)(i,"defaultProps",{onlyMedia:!1}),Object(d.a)(i,"contextTypes",{router:m.a.object}),o=a))||o)||o}}]);
//# sourceMappingURL=public_timeline.js.map