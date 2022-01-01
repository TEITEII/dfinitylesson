import Int "mo:base/Int";
import quickSort "quickSort";

actor Main {

  public query func qsort(arr : [Int]) : async [Int] {
    return quickSort.quickSortMain(arr, Int.compare);
  };
};