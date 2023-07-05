# 可迭代映射（Iterable Mapping）

在solidity中，mapping为内存映射，不可以迭代，但是我们可以通过扩展数据结构来使得mapping可迭代访问

即通过将映射得键存储在数组中，通过循环遍历数组来访问映射得值

```solidity
struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }
```

在Map结构体中，通过address数组keys记录mapping的address，通过访问kyes的地址达到对mapping的遍历，indexOf映射中记录了地址在数组当中的 位置



### mapping 的读写

在可迭代映射中，映射的更新操作增加了记录key的操作，映射的value更新无变化

```solidity
 function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        address lastKey = map.keys[map.keys.length - 1];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
```

