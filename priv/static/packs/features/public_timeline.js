(window.webpackJsonp=window.webpackJsonp||[]).push([[44],{834:function(e,t,n){"use strict";n.r(t);var o,i,c,a=n(0),l=n(2),d=n(7),r=n(1),s=n(3),u=n.n(s),p=n(13),b=n(6),h=n(5),m=n.n(h),f=n(1036),j=n(736),O=n(733),g=n(33),M=n(250),y=n(1139),v=n(70),I=Object(p.connect)((function(e,t){var n=t.columnId,o=e.getIn(["settings","columns"]),i=o.findIndex((function(e){return e.get("uuid")===n}));return{settings:n&&i>=0?o.get(i).get("params"):e.getIn(["settings","public"])}}),(function(e,t){var n=t.columnId;return{onChange:function(t,o){e(n?Object(M.f)(n,t,o):Object(v.c)(["public"].concat(t),o))}}}))(y.a),w=n(740);n.d(t,"default",(function(){return U}));var C=Object(b.f)({title:{id:"column.public",defaultMessage:"Federated timeline"}}),U=Object(p.connect)((function(e,t){var n=t.columnId,o=n,i=e.getIn(["settings","columns"]),c=i.findIndex((function(e){return e.get("uuid")===o})),a=n&&c>=0?i.get(c).getIn(["params","other","onlyMedia"]):e.getIn(["settings","public","other","onlyMedia"]),l=e.getIn(["timelines","public"+(a?":media":"")]);return{hasUnread:!!l&&l.get("unread")>0,onlyMedia:a}}))(o=Object(b.g)((c=i=function(e){function t(){for(var t,n=arguments.length,o=new Array(n),i=0;i<n;i++)o[i]=arguments[i];return t=e.call.apply(e,[this].concat(o))||this,Object(r.a)(Object(l.a)(t),"handlePin",(function(){var e=t.props,n=e.columnId,o=e.dispatch,i=e.onlyMedia;o(n?Object(M.h)(n):Object(M.e)("PUBLIC",{other:{onlyMedia:i}}))})),Object(r.a)(Object(l.a)(t),"handleMove",(function(e){var n=t.props,o=n.columnId;(0,n.dispatch)(Object(M.g)(o,e))})),Object(r.a)(Object(l.a)(t),"handleHeaderClick",(function(){t.column.scrollTop()})),Object(r.a)(Object(l.a)(t),"setRef",(function(e){t.column=e})),Object(r.a)(Object(l.a)(t),"handleLoadMore",(function(e){var n=t.props,o=n.dispatch,i=n.onlyMedia;o(Object(g.v)({maxId:e,onlyMedia:i}))})),t}Object(d.a)(t,e);var n=t.prototype;return n.componentDidMount=function(){var e=this.props,t=e.dispatch,n=e.onlyMedia;t(Object(g.v)({onlyMedia:n})),this.disconnect=t(Object(w.e)({onlyMedia:n}))},n.componentDidUpdate=function(e){if(e.onlyMedia!==this.props.onlyMedia){var t=this.props,n=t.dispatch,o=t.onlyMedia;this.disconnect(),n(Object(g.v)({onlyMedia:o})),this.disconnect=n(Object(w.e)({onlyMedia:o}))}},n.componentWillUnmount=function(){this.disconnect&&(this.disconnect(),this.disconnect=null)},n.render=function(){var e=this.props,t=e.intl,n=e.shouldUpdateScroll,o=e.columnId,i=e.hasUnread,c=e.multiColumn,l=e.onlyMedia,d=!!o;return u.a.createElement(j.a,{bindToDocument:!c,ref:this.setRef,label:t.formatMessage(C.title)},Object(a.a)(O.a,{icon:"globe",active:i,title:t.formatMessage(C.title),onPin:this.handlePin,onMove:this.handleMove,onClick:this.handleHeaderClick,pinned:d,multiColumn:c},void 0,Object(a.a)(I,{columnId:o})),Object(a.a)(f.a,{timelineId:"public"+(l?":media":""),onLoadMore:this.handleLoadMore,trackScroll:!d,scrollKey:"public_timeline-"+o,emptyMessage:Object(a.a)(b.b,{id:"empty_column.public",defaultMessage:"There is nothing here! Write something publicly, or manually follow users from other servers to fill it up"}),shouldUpdateScroll:n,bindToDocument:!c}))},t}(u.a.PureComponent),Object(r.a)(i,"contextTypes",{router:m.a.object}),Object(r.a)(i,"defaultProps",{onlyMedia:!1}),o=c))||o)||o}}]);
//# sourceMappingURL=public_timeline.js.map