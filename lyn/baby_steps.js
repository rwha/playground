var nums = process.argv
var res = 0
for (i=2; i<nums.length; i++) {
 res += +nums[i];
}
console.log(res);
