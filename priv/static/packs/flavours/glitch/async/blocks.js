(window.webpackJsonp=window.webpackJsonp||[]).push([[45],{665:function(t,e,a){"use strict";a.r(e),a.d(e,"default",function(){return y});var c,o,n,s=a(0),i=a(3),l=a(7),r=a(1),d=(a(2),a(24)),u=a(27),p=a.n(u),b=a(5),h=a.n(b),j=a(271),O=a(426),f=a(624),g=a(629),v=a(600),m=a(360),k=a(6),w=a(25),S=Object(k.f)({heading:{id:"column.blocks",defaultMessage:"Blocked users"}}),y=Object(d.connect)(function(t){return{accountIds:t.getIn(["user_lists","blocks","items"])}})(c=Object(k.g)((n=o=function(o){function t(){for(var a,t=arguments.length,e=new Array(t),c=0;c<t;c++)e[c]=arguments[c];return a=o.call.apply(o,[this].concat(e))||this,Object(r.a)(Object(i.a)(a),"handleScroll",function(t){var e=t.target;e.scrollTop===e.scrollHeight-e.clientHeight&&a.props.dispatch(Object(m.c)())}),Object(r.a)(Object(i.a)(a),"shouldUpdateScroll",function(t,e){var a=e.location;return!(((t||{}).location||{}).state||{}).mastodonModalOpen&&!(a.state&&a.state.mastodonModalOpen)}),a}Object(l.a)(t,o);var e=t.prototype;return e.componentWillMount=function(){this.props.dispatch(Object(m.d)())},e.render=function(){var t=this.props,e=t.intl,a=t.accountIds;return a?Object(s.a)(f.a,{name:"blocks",icon:"ban",heading:e.formatMessage(S.heading)},void 0,Object(s.a)(g.a,{}),Object(s.a)(O.a,{scrollKey:"blocks",shouldUpdateScroll:this.shouldUpdateScroll},void 0,Object(s.a)("div",{className:"scrollable",onScroll:this.handleScroll},void 0,a.map(function(t){return Object(s.a)(v.a,{id:t},t)})))):Object(s.a)(f.a,{},void 0,Object(s.a)(j.a,{}))},t}(w.a),Object(r.a)(o,"propTypes",{params:h.a.object.isRequired,dispatch:h.a.func.isRequired,accountIds:p.a.list,intl:h.a.object.isRequired}),c=n))||c)||c}}]);
//# sourceMappingURL=blocks.js.map