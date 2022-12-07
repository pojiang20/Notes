在写文件上传功能的时候，我发现Put和Post都可以用来上传文件。
> PUT上传中参数通过请求头域传递；POST上传则作为消息体中的表单域传递。
PUT上传需在URL中指定对象名；POST上传提交的URL为桶域名，无需指定对象名。- [华为云](https://support.huaweicloud.com/obs_faq/obs_faq_0071.html)

> 表单上传适用于文件内容可以在一次 HTTP 请求即可传递完成的场景。该功能非常适合在浏览器中使用 HTML 表单上传资源，或者在不需要处理复杂情况的客户端开发中使用。如果文件较大（大于 1GB），或者网络环境较差，可能会导致 HTTP 连接超时而上传失败。若发生这种情况，您需要考虑换用更安全的分片上传功能。 - [七牛云](https://developer.qiniu.com/kodo/1272/form-upload)

简而言之，Post作为表单上传，适用于一次性传输不大的文件。Put作为分片上传，可以不连续的多次传输文件的一部分。

StackOverFlow有Put和Post的[讨论](https://stackoverflow.com/questions/6273560/put-vs-post-for-uploading-files-restful-api-to-be-built-using-zend-framework)简单总结如下：
- put和post的区别的关键不在于替换和创建，而在于幂等性和资源命名。
- put是一个幂等操作，put操作可以提供资源名称和资源内容。因此多个操作可能是幂等的。
- post是非幂等操作，不需要提供资源名称，每次操作都是新操作，因此适用于创建新资源。
