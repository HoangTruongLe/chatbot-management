module ApplicationHelper
  def format_datetime(datetime)
    datetime.try(:strftime, '%Y/%m/%d %H:%M')
  end

  def format_datetime_ymd(datetime)
    datetime.try(:strftime, '%Y/%m/%d')
  end

  def format_boolean(bool)
  	bool ? "◯" : "✕"
  end

  def format_activity(bool)
    bool ? "有効" : "無効"
  end

  def active_namespace(namespace, action = nil)
    if (action)
      name = request.path
      return name.include?(namespace) && name.include?(action) ? true : false
    else
      name = request.path.split('/')[1]
      return name == namespace ? true : false
    end
  end

  def split_string_to_array(*str)
    arr = str.join(',').split(',')
    arr.delete("")
    arr
  end

  def format_script(api_key, aibot_address, server_host)
    %Q(<style>#aicb_iframe{position:fixed;right:0;bottom:0;z-index:10000;width:30%}@media screen and (max-width:1024px){#aicb_iframe{width:50%}}@media screen and (max-width:768px){#aicb_iframe{width:100%}}.disable_scroll{position:fixed;overflow:hidden}</style><script type="text/javascript">function aicb_isMobile(){return navigator.userAgent.match(/Android/i)||navigator.userAgent.match(/webOS/i)||navigator.userAgent.match(/iPhone/i)||navigator.userAgent.match(/iPad/i)||navigator.userAgent.match(/iPod/i)||navigator.userAgent.match(/BlackBerry/i)||navigator.userAgent.match(/Windows Phone/i)?!0:!1}function getMetaKeywords(){for(var e=document.getElementsByTagName("meta"),t=0;t<e.length;t++)if("keywords"==e[t].getAttribute("name")||"Keywords"==e[t].getAttribute("name"))return e[t].getAttribute("content");return""}function receiveMessage(e){void 0!=e.data.isOpened&&("true"===e.data.isOpened?(enable_native_touch(),document.getElementById("aicb_iframe").style.height="100%"):(disable_native_touch(),document.getElementById("aicb_iframe").style.height="90px"),document.getElementById("aicb_iframe").contentWindow.postMessage({iframe_height:window.innerHeight.toString()},aicb_host))}function enable_native_touch(){aicb_isMobile()&&document.body.classList.add("disable_scroll")}function disable_native_touch(){aicb_isMobile()&&document.body.classList.remove("disable_scroll")}function aicb_ajax(e,t,n){return new Promise(function(n,a){var i=new XMLHttpRequest;i.open(e,server_host+t),i.setRequestHeader("Content-Type","application/json"),i.setRequestHeader("Authorization",'Token token="'+api_key+'"'),i.onload=function(){200===i.status?n(i.response):a({status:this.status,statusText:i.statusText})},i.onerror=function(){a({status:this.status,statusText:i.statusText})},i.send()})}var aicb_host="#{aibot_address}",api_key="#{api_key}",server_host="#{server_host}";window.addEventListener("resize",function(){null!==document.getElementById("aicb_iframe")&&document.getElementById("aicb_iframe").contentWindow.postMessage({iframe_height:window.innerHeight.toString()},aicb_host)},!1),document.addEventListener("DOMContentLoaded",function(){var e=getMetaKeywords(),t=!0;aicb_ajax("get","/v1/existed_open_keyword.json?meta_keywords="+e,{}).then(function(e){if(e=JSON.parse(e),"false"==e.existed&&(t=!1),t){var n=document.createElement("iframe");n.onload=function(){document.getElementById("aicb_iframe").contentWindow.postMessage({api_key:api_key,meta_keywords:getMetaKeywords(),text_message:e.text_message},aicb_host)},n.setAttribute("src",aicb_host),n.style.height="90px",n.style.border="none",n.id="aicb_iframe",document.body.appendChild(n)}})["catch"](function(e){console.error("Augh, there was an error!",e.statusText)})}),window.addEventListener("message",receiveMessage,!1);</script>)
  end
end
