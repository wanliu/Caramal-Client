# Caramal Client design specification

### 引用

```html
<SCRIPT type='type/javascript' src='.../caramal_client.js'></SCRIPT>
```


### 使用

```js
  window.client = Caramal.connect({ url: 'host', token: 'adfasdfasdfadsf'});
    
  // 重复使用
  window.client = window.client ||
                          Caramal.connect({ url: 'host', token: 'adfasdfasdfadsf'});
```


### 状态事件绑定

```js

  // 连接成功
  client.on('connect', function () {
    console.log('connected');
  });

  // 连接中... 
  client.on('connecting', function () {
    console.log('connecting');
  });
  
  // 断开连接 error 是错误提示, booted  被踢
  client.on('disconnect', function (error) {
    console.log('disconnect' + error);
  });

  // 连接失败
  client.on('connect_failed', function () {
    console.log('connect_failed');
  });
  
  // 发生错误
  client.on('error', function (err) {
    console.log('error: ' + err);
  });
  
  // 重连失败
  client.on('reconnect_failed', function () {
    console.log('reconnect_failed');
  });
  
  // 重新连接成功
  client.on('reconnect', function () {
    console.log('reconnected ');
  });
  
  // 重新连接中...
  client.on('reconnecting', function () {
    console.log('reconnecting');
  });

```

### 订阅通知

```js 
  client.subscribe('/transactions/completed', function(data){
    //...
  });
  
  client.subscribe('/transactions/1/completed', function(data){
    //...
  });  
```

取消订阅

```js 
  client.unsubscribe('/transactions/completed');
```

### 发布通知
目前来说，会设计在服务器，因为发布跟与数据持久有关，所以我们希望在服务端进行

```ruby
  # public publish
  # login: String 用户名
  # channel: 频道名
  # msg:  消息， 消息格式 Hash
  # 例子:
  require 'caramal_client'
  
  CaramalClient.publish('hysios', '/transcations', {:id => 1234 })
```

### 发送消息 
```js
  client.emit('join', JSON.stringify({room: info.room});
```

# 聊天对话部分
聊天对话这块的设计，我打算用另一个UI层的包容来实现，也就是他的实现类并非是 CaramalClient, CaramalClient 只是
通信实现的部分，通常只处理通信，事件绑定与协议这层的事物

### 引用
```html
<SCRIPT type='type/javascript' src='.../caramal-chat.js'></SCRIPT>
```

### 使用

```js
  Caramal.MessageManager.setClient(clients.client)
  
  chat = Caramal.Chat.create('hysios');
  
  // 绑定消息显示
  chat.onMessage(function(msg) {
     console.log(msg);
  })
  
  // 绑定错误处理
  
  chat.onError(function(error) {
     console.log(error);
  });
  
  // 打开频道
  chat.open()
  
  // 输出 room id 
  chat.room
  
  // 发送消息
  
  chat.send('hi')
  
  // 你会看到这样一个信息输出在控制台
  // => Object {msg: "hi", user: "hyysios", action: "chat"} 
```

