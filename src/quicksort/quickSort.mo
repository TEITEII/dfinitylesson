import Array "mo:base/Array";
import Order "mo:base/Order";
import Int "mo:base/Int";

module quickSort {

  type Order = Order.Order;

  // 快速排序主函数，定义数组类型
  public func quickSortMain(arr : [Int], sort : (Int, Int) -> Order) : [Int] {
    let len = arr.size();
    // 将不可变数组转换为可变数组
    let result = Array.thaw<Int>(arr);
    
    partition(result, 0, len - 1, sort);
    return Array.freeze(result);
  };

  // 将数组进行分区排序
  private func partition(arr : [var Int], left : Int, right : Int, sort : (Int, Int) -> Order,) {
    if (left < right) {
      var i = left;
      var j = right;
      var swap  = arr[0];
      // 获取中间基准值
      let pivot = arr[Int.abs(left + right) / 2];
      while (i <= j) {
        // 排序分区一（左）
        while (Order.isLess(sort(arr[Int.abs(i)], pivot))) {
          i += 1;
        };
        // 排序分区二（右）
        while (Order.isGreater(sort(arr[Int.abs(j)], pivot))) {
          j -= 1;
        };
        // 对数组中数值进行比较排序
        if (i <= j) {
          swap := arr[Int.abs(i)];
          arr[Int.abs(i)] := arr[Int.abs(j)];
          arr[Int.abs(j)] := swap;
          i += 1;
          j -= 1;
        };
      };
      if (left < j) {
        partition(arr, left, j, sort);
      };
      if (i < right) {
        partition(arr, i, right, sort);
      };
    };
  };
};