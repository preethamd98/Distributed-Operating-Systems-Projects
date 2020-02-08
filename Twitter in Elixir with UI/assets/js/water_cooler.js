  
let WaterCooler = {
    init(socket) {
      let channel = socket.channel('water_cooler:lobby', {})
      channel.join()
      this.listenForChats(channel)
    },
  
    listenForChats(channel) {
      document.getElementById("login").onclick = function(e){
        e.preventDefault()
        let nn = document.getElementById('login-name').value
        channel.push('login',{name:nn})
    }

    document.getElementById("subscribe-button").onclick = function(e){
      e.preventDefault()
      let name = document.getElementById('login-name').value
      let nn = document.getElementById('subscribe').value
      channel.push('subscribe',{name:name,subscriber:nn})
  }
  document.getElementById("test").onclick = function(e){
    e.preventDefault()
    channel.push('test',{})
}
document.getElementById("retweet-button").onclick = function(e){
  e.preventDefault()
  let name = document.getElementById('login-name').value
  let id = document.getElementById('retweet').value
  channel.push('retweet',{name:name,retweetid:id})
}


  channel.on('new_msg',payload =>{
    let chatBox = document.querySelector('#chat-box')
    let msgBlock = document.createElement('p')
    msgBlock.insertAdjacentHTML('beforeend', payload.body)
    chatBox.appendChild(msgBlock)
  })

  document.getElementById("tweet-button").onclick = function(e){
    e.preventDefault()
    let name = document.getElementById('login-name').value
    let tweet = document.getElementById('tweet-text').value
    channel.push('tweet',{name:name,tweet:tweet})

  }

  document.getElementById("hashtag-button").onclick = function(e){
    e.preventDefault()
    let name = document.getElementById('login-name').value
    let query = document.getElementById('hashtag').value
    channel.push('hashtags',{name:name,query:query})

  }
channel.on('hashtags',payload =>{
  let chatBox = document.querySelector('#chat-box')
  let msgBlock = document.createElement('p')
  msgBlock.insertAdjacentHTML('beforeend', payload.query)
  chatBox.appendChild(msgBlock)


})



document.getElementById("mymentions-button").onclick = function(e){
  e.preventDefault()
  let name = document.getElementById('login-name').value
  let query = "@"+name
  console.log(query)
  channel.push('mentions',{name:name,query:query})

}




document.getElementById("mentions-button").onclick = function(e){
  e.preventDefault()
  let name = document.getElementById('login-name').value
  let query = document.getElementById('mentions').value
  channel.push('mentions',{name:name,query:query})

}
channel.on('mentions',payload =>{
let chatBox = document.querySelector('#chat-box')
let msgBlock = document.createElement('p')
msgBlock.insertAdjacentHTML('beforeend', payload.query)
chatBox.appendChild(msgBlock)


})













  channel.on('subscribe',payload => {
    let chatBox = document.querySelector('#chat-box')
    let msgBlock = document.createElement('p')

    if(payload.status==0){
      msgBlock.insertAdjacentHTML('beforeend', `successfully added the subscriber`)
      
    }
    else{
      msgBlock.insertAdjacentHTML('beforeend', `The user is not found please enter the correct user name`)

    }
    document.getElementById('subscribe').value = ''
    chatBox.appendChild(msgBlock)

    
  })










    channel.on('login',payload => {
      let chatBox = document.querySelector('#chat-box')
      let msgBlock = document.createElement('p')

      if(payload.status==0){
        msgBlock.insertAdjacentHTML('beforeend', `The user is not found please enter the correct user name`)
        document.getElementById('login-name').value = ''
      }
      else{
        msgBlock.insertAdjacentHTML('beforeend', `Logged in sucessfully`)
        let name = document.querySelector('#name')
        let Block = document.createElement('h3')
        let nn = document.getElementById('login-name').value
        Block.insertAdjacentHTML('beforeend', `Hello `+nn+` Welcome back!!`)
        name.appendChild(Block)

      }
      chatBox.appendChild(msgBlock)

      
    })



      document.getElementById("register").onclick = function(e){
        e.preventDefault()
        let nn = document.getElementById('login-name').value
        channel.push('register',{name:nn})


    }
    channel.on('register',payload => {
      let chatBox = document.querySelector('#chat-box')
      let msgBlock = document.createElement('p')
      //Finish this code

      


      if(payload.status==1){
        msgBlock.insertAdjacentHTML('beforeend', `registration successful`)
      }
      else{
        msgBlock.insertAdjacentHTML('beforeend', `registration unsuccessful please try out with a different name`)
        document.getElementById('login-name').value = ''

      }
      chatBox.appendChild(msgBlock)

      
    })
    

    }
  }
  
export default WaterCooler