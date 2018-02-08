最初是打算给<一步一步构建你的网络层-HTTP篇>配一个带本地服务器的Demo的, 后来想了想, TCP和WebSocket其实也需要配本地服务器, 于是就把这三个Demo揉到一起了, 后来又想了想, 干脆把之前所有博客的Demo都放到一起算了, 这个Demo就是TObjective-C.
目前TObjective-C分两个部分: TObjective-C(客户端)和TObjectiveCServer(本地服务器).

TObjective-C这边目前完成的部分有:
1. 比较接近我实际开发的分层设计
2. 比较接近我实际开发MVVM和Router示例
3. 简单的HTTP网络层
4. 简单的TCP网络层
5. 简单的WebSocket网络层
后续可能会加上其他博客或者没写到博客里的示例 有时间的话
ps: 三个网络层目前看来是有一致的接口但是却没有抽象成一个协议 这看起来可能不太合理 但如上文所述 这三个网络层分别来自三个完全不同的Demo 实际开发也不可能会同时出现在一个项目 所以并没有进行抽象 望知悉.


TObjectiveCServer我用golang写的测试服务器 mac下双击TObjectiveCServer执行将会执行以下事件:

1. 读取同目录下的Weibo文件作为数据源
2. 在本机12345端口开启一个简单的HTTP服务器
3. 在本机23456端口开启一个简单的TCP服务器
4. 在本机34567端口开启一个简单的WebSocket服务器

服务器的数据来源都是Weibo文件, 另外TCP和WebSocket服务器每隔70或90秒会向客户端发送一条推送, 某些网络请求还会触发Ping-Pong.