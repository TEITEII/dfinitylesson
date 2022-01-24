import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Time "mo:base/Time";

actor {
    // 创建 record 类型，加入 time 字段和 author 字段
    public type Message = {
        content: Text;
        time: Time.Time;
        author: Text;
    };
    public type Followed = {
        id: Principal;
        author: ?Text;
    };
    
    // 声明方法类型与返回值类型
    public type Microblog = actor {
        follow: shared(Principal) -> async (); // 添加关注对象
        follows: shared query () -> async [Principal]; // 返回关注列表
        post: shared (Text, Text) -> async (); // 发布新消息
        posts: shared query () -> async [Message]; // 返回所有发布的消息
        timeline: shared () -> async [Message]; // 返回所有关注对象发布的消息
        get_name: shared () -> async ?Text;
        set_name: shared (Text) -> async ();
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
    // 创建作者
    stable var author = "TEI";
    public shared func set_name(name: Text) : () {
        author := name;
    };
    // 获取作者
    public shared func get_name() : async ?Text {
        ?author;
    };

    // 发布新消息，并生成更新时间
    stable var messages : List.List<Message> = List.nil();
    public shared(msg) func post(otp: Text, content: Text) : async () {
        assert(otp == "123456");
        let now = Time.now();
        let message : Message = {content = content; time = now; author = author};
        messages := List.push(message, messages);
    };
    // 返回所有发布的消息和更新时间
    public shared query func posts() : async [Message] {
        List.toArray(messages)
    };
    // 返回所有关注对象发布的消息和更新时间
    public shared func timeline() : async [Message] {
        var all : List.List<Message> = List.nil();

        for (id in Iter.fromList(followed)) {
            let canister : Microblog = actor(Principal.toText(id));
            let msgs = await canister.posts();
            for (msg in Iter.fromArray(msgs)) {
                all := List.push(msg, all)
            }
        };
        List.toArray(all)
    };
}
