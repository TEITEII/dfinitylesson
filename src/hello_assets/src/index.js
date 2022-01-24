import { Nat } from "@dfinity/candid/lib/cjs/idl";
import { hello } from "../../declarations/hello";
export const canisterId = process.env.MICROBLOG_CANISTER_ID;

// 将时间戳转化为时间
function dateFormat(time) {
  var timeStamp = Number(time / 1000000n);
  var ymd = new Date(timeStamp),
        y = ymd.getFullYear(),
        m = ymd.getMonth() + 1,
        d = ymd.getDate();
  return y + "-" + (m < 10 ? "0" + m : m) + "-" + (d < 10 ? "0" + d : d) + " " + ymd.toTimeString().substr(0, 8);
}
// post方法，发布消息
async function post() {
  let post_button = document.getElementById("post");
  let error = document.getElementById("error");
  error.innerText = "";
  post_button.disabled = true;
  let textarea = document.getElementById("message");
  let otp = document.getElementById("otp").value;
  let text = textarea.value;
  try {
    await hello.post(otp, text);
    textarea.value = "";
  } catch (err) {
    console.log(err)
    error.innerText = "Post Failed!";
  }
  post_button.disabled = false;
}
// posts方法，请求消息列表，并返回消息内容、发布时间和作者。
var num_posts = 0;
async function load_posts() {
  let posts_section = document.getElementById("posts");
  let posts = await hello.posts();
  // 获取消息数组
  if (num_posts == posts.length) return;
  posts_section.replaceChildren([]);
  num_posts = posts.length;
  for (var i=0; i < posts.length; i++) {
    // 获取消息内容
    let post_content = document.createElement("td");
    post_content.innerText = "　更新内容：\n" + "　" + posts[i].content
    posts_section.appendChild(post_content)
    // 获取发布时间
    let post_time = document.createElement("p");
    post_time.innerText = "　更新時間：" + dateFormat(posts[i].time)
    posts_section.appendChild(post_time)
    // 获取作者
    let post_author = document.createElement("p");
    post_author.innerText = "　作者：" + posts[i].author
    posts_section.appendChild(post_author)
  }
}
// follows方法，获取消息列表
var num_follows = 0;
async function load_follows() {
  let follows_section = document.getElementById("follows");
  let follows = await hello.follows();
  // 获取关注者列表
  if (num_follows == follows.length) return;
  follows_section.replaceChildren([]);
  num_follows = follows.length;
  for (var j=0; j < follows.length; j++) {
    let followed_authorID = document.createElement("li");
    followed_authorID.innerText = follows[j]
    follows_section.appendChild(followed_authorID)
  }
}
// timeline方法，获取关注者消息列表，并返回消息内容、发布时间和作者
var num_timeline = 0;
async function load_timeline() {
  let timeline_section = document.getElementById("timeline");
  let timeline = await hello.timeline();
  // 获取所有关注者的消息列表
  if (num_timeline == timeline.length) return;
  timeline_section.replaceChildren([]);
  num_timeline = timeline.length;
  for (var k=0; k < timeline.length; k++) {
    // 获取消息内容
    let update_content = document.createElement("td");
    update_content.innerText = "\n" + "　更新内容：\n" + "　" + timeline[k].content
    timeline_section.appendChild(update_content) 
    // 获取发布时间
    let update_time = document.createElement("p");
    update_time.innerText = "　更新時間：" + dateFormat(timeline[k].time)
    timeline_section.appendChild(update_time)
    // 获取作者
    let update_author = document.createElement("p");
    update_author.innerText = "　作者：" + timeline[k].author + "\n"
    timeline_section.appendChild(update_author)
  }
}

function load() {
  let post_button = document.getElementById("post");
  post_button.onclick = post;
  load_posts()
  setInterval(load_posts, 3000)
  load_follows()
  setInterval(load_follows, 3000)
  load_timeline()
  setInterval(load_timeline, 3000)
}

window.onload = load