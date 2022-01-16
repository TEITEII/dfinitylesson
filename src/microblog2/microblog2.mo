import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Time "mo:base/Time";

actor {
    // 声明 record 类型，加入 time 字段
    public type Message = {
        text: Text;
        time: Time.Time;
    };
    // 声明方法类型与返回值类型
    public type Microblog = actor {
        follow: shared(Principal) -> async (); // 添加关注对象
        follows: shared query () -> async [Principal]; // 返回关注列表
        post: shared (Text) -> async (); // 发布新消息
        posts: shared query (Time.Time) -> async [Message]; // 返回所有发布的消息
        timeline: shared (Time.Time) -> async [Message]; // 返回所有关注对象发布的消息
    };
    
    stable var followed : List.List<Principal> = List.nil();
    // 添加关注对象
    public shared func follow(id: Principal) : async () {
        followed := List.push(id, followed);
    };
    // 返回关注列表
    public shared query func follows() : async [Principal] {
        List.toArray(followed)
    };
    // 发布新消息，并生成更新时间
    stable var messages : List.List<Message> = List.nil();
    public shared(msg) func post(text: Text) : async () {
        // 获取Unix时间戳，单位为秒(s)
        let now = Time.now();
        let timestamp = now / 1000_000_000;
        // 对 message 进行赋值
        let message : Message = {text = text; time = timestamp};
        // 返回消息列表
        messages := List.push(message, messages);
    };
    // 返回发布的消息和更新时间
    public shared query func posts(since: Time.Time) : async [Message] {
        for (message in Iter.fromList(messages)) {
            // 筛选指定时间之后的信息并返回列表
            if (since < message.time) {
            messages := List.push(message, messages);
            }
        };
        // 将列表转化为数组类型并返回
        List.toArray(messages)
    };
    // 返回关注对象发布的消息和更新时间
    public shared func timeline(since: Time.Time) : async [Message] {
        var all : List.List<Message> = List.nil();
        // 遍历关注对象列表，获取所有关注对象的消息
        for (id in Iter.fromList(followed)) {
            // 获取关注对象的 canisterID
            let canister : Microblog = actor(Principal.toText(id));
            // 获取关注对象的消息
            let msgs = await canister.posts(since: Time.Time);
            // 遍历消息数组
            for (msg in Iter.fromArray(msgs)) {
                // 筛选出指定时间后的消息
                if (since < msg.time) {
                    // 返回消息列表
                    all := List.push(msg, all);
                }               
            }
        };
        // 将消息列表转化成数组并返回
        List.toArray(all)
    };
}