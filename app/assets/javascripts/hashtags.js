function make_hashtags(source){
  return source.replace(/\B[\#|\@]\w+/gi, function(match) { return match.link('/' + match.replace('#', '!')); })
}

$(document).ready(function(){
 $(".post_body").each(function(){
 	$(this).html(make_hashtags($(this).text()));
 });
});