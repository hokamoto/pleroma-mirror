(window.webpackJsonp=window.webpackJsonp||[]).push([[56],{658:function(a,t,c){"use strict";c.r(t),c.d(t,"default",function(){return S});var o,e,s,n=c(0),r=c(3),p=c(7),l=c(1),i=c(2),d=c.n(i),u=c(24),h=c(5),b=c.n(h),O=c(27),j=c.n(O),f=c(271),m=c(22),I=c(426),v=c(600),w=c(624),M=c(908),g=c(912),k=c(906),H=c(25),S=Object(u.connect)(function(a,t){return{accountIds:a.getIn(["user_lists","followers",t.params.accountId,"items"]),hasMore:!!a.getIn(["user_lists","followers",t.params.accountId,"next"])}})((s=e=function(e){function a(){for(var c,a=arguments.length,t=new Array(a),o=0;o<a;o++)t[o]=arguments[o];return c=e.call.apply(e,[this].concat(t))||this,Object(l.a)(Object(r.a)(c),"handleHeaderClick",function(){c.column.scrollTop()}),Object(l.a)(Object(r.a)(c),"handleScroll",function(a){var t=a.target;t.scrollTop===t.scrollHeight-t.clientHeight&&c.props.hasMore&&c.props.dispatch(Object(m.D)(c.props.params.accountId))}),Object(l.a)(Object(r.a)(c),"handleLoadMore",function(a){a.preventDefault(),c.props.dispatch(Object(m.D)(c.props.params.accountId))}),Object(l.a)(Object(r.a)(c),"shouldUpdateScroll",function(a,t){var c=t.location;return!(((a||{}).location||{}).state||{}).mastodonModalOpen&&!(c.state&&c.state.mastodonModalOpen)}),Object(l.a)(Object(r.a)(c),"setRef",function(a){c.column=a}),c}Object(p.a)(a,e);var t=a.prototype;return t.componentWillMount=function(){this.props.dispatch(Object(m.F)(this.props.params.accountId)),this.props.dispatch(Object(m.H)(this.props.params.accountId))},t.componentWillReceiveProps=function(a){a.params.accountId!==this.props.params.accountId&&a.params.accountId&&(this.props.dispatch(Object(m.F)(a.params.accountId)),this.props.dispatch(Object(m.H)(a.params.accountId)))},t.render=function(){var a=this.props,t=a.accountIds,c=a.hasMore,o=null;return t?(c&&(o=Object(n.a)(k.a,{onClick:this.handleLoadMore})),d.a.createElement(w.a,{ref:this.setRef},Object(n.a)(M.a,{onClick:this.handleHeaderClick}),Object(n.a)(I.a,{scrollKey:"followers",shouldUpdateScroll:this.shouldUpdateScroll},void 0,Object(n.a)("div",{className:"scrollable",onScroll:this.handleScroll},void 0,Object(n.a)("div",{className:"followers"},void 0,Object(n.a)(g.a,{accountId:this.props.params.accountId,hideTabs:!0}),t.map(function(a){return Object(n.a)(v.a,{id:a,withNote:!1},a)}),o))))):Object(n.a)(w.a,{},void 0,Object(n.a)(f.a,{}))},a}(H.a),Object(l.a)(e,"propTypes",{params:b.a.object.isRequired,dispatch:b.a.func.isRequired,accountIds:j.a.list,hasMore:b.a.bool}),o=s))||o}}]);
//# sourceMappingURL=followers.js.map