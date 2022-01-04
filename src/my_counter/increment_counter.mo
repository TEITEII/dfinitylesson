import Text "mo:base/Text";
import Nat "mo:base/Nat";

actor Counter {

stable var counter = 0;

// 获得自然数.
public query func get() : async Nat {
    return counter;
    };

// 设定自然数.
public func set(n : Nat) : async () {
    counter := n;
    };

// 累加自然数.
public func inc() : async () {
    counter += 1;
    };

// HTTP请求的类型声明
public type HeaderField = (Text, Text);
public type HttpRequest = {
    url : Text;
    method : Text;
    body : [Nat8];
    headers : [HeaderField];
    };

public type HttpResponse = {
    body : Blob;
    headers : [HeaderField];
    streaming_strategy : ?StreamingStrategy;
    status_code : Nat16;
    }; 

public type Key = Text;
public type Path = Text;
public type ChunkId = Nat;

public type SetAssetContentArguments = {
    key : Key;
    sha256 : ?[Nat8];
    chunk_ids : [ChunkId];
    content_encoding : Text;
    };

public type StreamingCallbackHttpResponse = {
    token : ?StreamingCallbackToken;
    body : [Nat8];
    };

public type StreamingCallbackToken = {
    key : Text;
    sha256 : ?[Nat8];
    index : Nat;
    content_encoding : Text;
    };

public type StreamingStrategy = {
    #Callback : {
      token : StreamingCallbackToken;
      callback : shared query StreamingCallbackToken -> async StreamingCallbackHttpResponse;
        };
    };

// HTTP请求体，获取自然数当前值并返回HTML
public shared query func http_request(request:HttpRequest): async HttpResponse {
    {
        body = Text.encodeUtf8("<html><body><h1>Count is "#Nat.toText(counter)#" now.<h1><body><html>");
        headers = [];
        streaming_strategy = null;
        status_code = 200;
    }
  }
};