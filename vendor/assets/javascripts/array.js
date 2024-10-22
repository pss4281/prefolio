"use strict";
angular.module("jackrabbitsgroup.angular-array", []).factory("jrgArray", [function() {
    function subSort2D(array1) {
        var left, right, beg = [],
            end = [],
            pivot = [];
        pivot[0] = [], pivot[0][0] = [], pivot[0][1] = [], pivot[1] = [], pivot[1][0] = [], pivot[1][1] = [];
        var count = 0;
        for (beg[0] = 0, end[0] = array1.length; count >= 0;) if (left = beg[count], right = end[count] - 1, right > left) {
            for (pivot[0][1] = array1[left][1], pivot[0][0] = array1[left][0]; right > left;) {
                for (; array1[right][1] >= pivot[0][1] && right > left;) right--;
                for (right > left && (array1[left][0] = array1[right][0], array1[left][1] = array1[right][1], left++); array1[left][1] <= pivot[0][1] && right > left;) left++;
                right > left && (array1[right][0] = array1[left][0], array1[right][1] = array1[left][1], right--)
            }
            array1[left][0] = pivot[0][0], array1[left][1] = pivot[0][1], beg[count + 1] = left + 1, end[count + 1] = end[count], end[count] = left, count++
        } else count--;
        return array1
    }
    return {
        remove: function(arrOrig, from, to, params) {
            console.log(arrOrig), void 0 === params && (params = {});
            var arr1;
            arr1 = void 0 !== params.modifyOriginal && params.modifyOriginal ? arrOrig : this.copy(arrOrig, {});
            var rest = arr1.slice((to || from) + 1 || arr1.length);
            return arr1.length = 0 > from ? arr1.length + from : from, arr1 = arr1.concat(rest)
        },
        findArrayIndex: function(array, key, val, params) {
            var ii, index = -1;
            if (params.oneD) {
                for (ii = 0; ii < array.length; ii++) if (array[ii] == val) {
                    index = ii;
                    break
                }
            } else for (ii = 0; ii < array.length; ii++) if (array[ii][key] == val) {
                index = ii;
                break
            }
            return index
        },
        sort2D: function(arrayUnsorted, column, params) {
            var ii, tempArray = [],
                array2D = [];
            for (ii = 0; ii < arrayUnsorted.length; ii++) tempArray[ii] = [], tempArray[ii] = arrayUnsorted[ii], array2D[ii] = [ii, tempArray[ii][column]];
            array2D = subSort2D(array2D);
            var sortedArray = [],
                counter = 0;
            if (void 0 !== params.order && "desc" == params.order) for (ii = array2D.length - 1; ii >= 0; ii--) sortedArray[counter] = tempArray[array2D[ii][0]], counter++;
            else for (ii = 0; ii < array2D.length; ii++) sortedArray[counter] = tempArray[array2D[ii][0]], counter++;
            return sortedArray
        },
        isArray: function(array1) {
            return "[object Array]" === Object.prototype.toString.apply(array1) ? !0 : !1
        },
        copy: function(array1, params) {
            var newArray, aa;
            if (!array1) return array1;
            if (params || (params = {}), params.skipKeys && void 0 !== params.skipKeys || (params.skipKeys = []), "object" != typeof array1) return array1;
            if (this.isArray(array1)) for (newArray = [], aa = 0; aa < array1.length; aa++) newArray[aa] = array1[aa] && "object" == typeof array1[aa] ? this.copy(array1[aa], params) : array1[aa];
            else {
                newArray = {};
                for (aa in array1) {
                    for (var goTrig = !0, ss = 0; ss < params.skipKeys.length; ss++) if (params.skipKeys[ss] == aa) {
                        goTrig = !1;
                        break
                    }
                    goTrig && (newArray[aa] = array1[aa] && "object" == typeof array1[aa] ? this.copy(array1[aa], params) : array1[aa])
                }
            }
            return newArray
        }
    }
}]);