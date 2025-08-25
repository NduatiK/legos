// build/dev/javascript/prelude.mjs
var CustomType = class {
  withFields(fields) {
    let properties = Object.keys(this).map(
      (label) => label in fields ? fields[label] : this[label]
    );
    return new this.constructor(...properties);
  }
};
var List = class {
  static fromArray(array3, tail) {
    let t = tail || new Empty();
    for (let i = array3.length - 1; i >= 0; --i) {
      t = new NonEmpty(array3[i], t);
    }
    return t;
  }
  [Symbol.iterator]() {
    return new ListIterator(this);
  }
  toArray() {
    return [...this];
  }
  // @internal
  atLeastLength(desired) {
    let current = this;
    while (desired-- > 0 && current) current = current.tail;
    return current !== void 0;
  }
  // @internal
  hasLength(desired) {
    let current = this;
    while (desired-- > 0 && current) current = current.tail;
    return desired === -1 && current instanceof Empty;
  }
  // @internal
  countLength() {
    let current = this;
    let length3 = 0;
    while (current) {
      current = current.tail;
      length3++;
    }
    return length3 - 1;
  }
};
function prepend(element5, tail) {
  return new NonEmpty(element5, tail);
}
function toList(elements, tail) {
  return List.fromArray(elements, tail);
}
var ListIterator = class {
  #current;
  constructor(current) {
    this.#current = current;
  }
  next() {
    if (this.#current instanceof Empty) {
      return { done: true };
    } else {
      let { head, tail } = this.#current;
      this.#current = tail;
      return { value: head, done: false };
    }
  }
};
var Empty = class extends List {
};
var NonEmpty = class extends List {
  constructor(head, tail) {
    super();
    this.head = head;
    this.tail = tail;
  }
};
var BitArray = class {
  /**
   * The size in bits of this bit array's data.
   *
   * @type {number}
   */
  bitSize;
  /**
   * The size in bytes of this bit array's data. If this bit array doesn't store
   * a whole number of bytes then this value is rounded up.
   *
   * @type {number}
   */
  byteSize;
  /**
   * The number of unused high bits in the first byte of this bit array's
   * buffer prior to the start of its data. The value of any unused high bits is
   * undefined.
   *
   * The bit offset will be in the range 0-7.
   *
   * @type {number}
   */
  bitOffset;
  /**
   * The raw bytes that hold this bit array's data.
   *
   * If `bitOffset` is not zero then there are unused high bits in the first
   * byte of this buffer.
   *
   * If `bitOffset + bitSize` is not a multiple of 8 then there are unused low
   * bits in the last byte of this buffer.
   *
   * @type {Uint8Array}
   */
  rawBuffer;
  /**
   * Constructs a new bit array from a `Uint8Array`, an optional size in
   * bits, and an optional bit offset.
   *
   * If no bit size is specified it is taken as `buffer.length * 8`, i.e. all
   * bytes in the buffer make up the new bit array's data.
   *
   * If no bit offset is specified it defaults to zero, i.e. there are no unused
   * high bits in the first byte of the buffer.
   *
   * @param {Uint8Array} buffer
   * @param {number} [bitSize]
   * @param {number} [bitOffset]
   */
  constructor(buffer, bitSize, bitOffset) {
    if (!(buffer instanceof Uint8Array)) {
      throw globalThis.Error(
        "BitArray can only be constructed from a Uint8Array"
      );
    }
    this.bitSize = bitSize ?? buffer.length * 8;
    this.byteSize = Math.trunc((this.bitSize + 7) / 8);
    this.bitOffset = bitOffset ?? 0;
    if (this.bitSize < 0) {
      throw globalThis.Error(`BitArray bit size is invalid: ${this.bitSize}`);
    }
    if (this.bitOffset < 0 || this.bitOffset > 7) {
      throw globalThis.Error(
        `BitArray bit offset is invalid: ${this.bitOffset}`
      );
    }
    if (buffer.length !== Math.trunc((this.bitOffset + this.bitSize + 7) / 8)) {
      throw globalThis.Error("BitArray buffer length is invalid");
    }
    this.rawBuffer = buffer;
  }
  /**
   * Returns a specific byte in this bit array. If the byte index is out of
   * range then `undefined` is returned.
   *
   * When returning the final byte of a bit array with a bit size that's not a
   * multiple of 8, the content of the unused low bits are undefined.
   *
   * @param {number} index
   * @returns {number | undefined}
   */
  byteAt(index4) {
    if (index4 < 0 || index4 >= this.byteSize) {
      return void 0;
    }
    return bitArrayByteAt(this.rawBuffer, this.bitOffset, index4);
  }
  /** @internal */
  equals(other) {
    if (this.bitSize !== other.bitSize) {
      return false;
    }
    const wholeByteCount = Math.trunc(this.bitSize / 8);
    if (this.bitOffset === 0 && other.bitOffset === 0) {
      for (let i = 0; i < wholeByteCount; i++) {
        if (this.rawBuffer[i] !== other.rawBuffer[i]) {
          return false;
        }
      }
      const trailingBitsCount = this.bitSize % 8;
      if (trailingBitsCount) {
        const unusedLowBitCount = 8 - trailingBitsCount;
        if (this.rawBuffer[wholeByteCount] >> unusedLowBitCount !== other.rawBuffer[wholeByteCount] >> unusedLowBitCount) {
          return false;
        }
      }
    } else {
      for (let i = 0; i < wholeByteCount; i++) {
        const a = bitArrayByteAt(this.rawBuffer, this.bitOffset, i);
        const b = bitArrayByteAt(other.rawBuffer, other.bitOffset, i);
        if (a !== b) {
          return false;
        }
      }
      const trailingBitsCount = this.bitSize % 8;
      if (trailingBitsCount) {
        const a = bitArrayByteAt(
          this.rawBuffer,
          this.bitOffset,
          wholeByteCount
        );
        const b = bitArrayByteAt(
          other.rawBuffer,
          other.bitOffset,
          wholeByteCount
        );
        const unusedLowBitCount = 8 - trailingBitsCount;
        if (a >> unusedLowBitCount !== b >> unusedLowBitCount) {
          return false;
        }
      }
    }
    return true;
  }
  /**
   * Returns this bit array's internal buffer.
   *
   * @deprecated Use `BitArray.byteAt()` or `BitArray.rawBuffer` instead.
   *
   * @returns {Uint8Array}
   */
  get buffer() {
    bitArrayPrintDeprecationWarning(
      "buffer",
      "Use BitArray.byteAt() or BitArray.rawBuffer instead"
    );
    if (this.bitOffset !== 0 || this.bitSize % 8 !== 0) {
      throw new globalThis.Error(
        "BitArray.buffer does not support unaligned bit arrays"
      );
    }
    return this.rawBuffer;
  }
  /**
   * Returns the length in bytes of this bit array's internal buffer.
   *
   * @deprecated Use `BitArray.bitSize` or `BitArray.byteSize` instead.
   *
   * @returns {number}
   */
  get length() {
    bitArrayPrintDeprecationWarning(
      "length",
      "Use BitArray.bitSize or BitArray.byteSize instead"
    );
    if (this.bitOffset !== 0 || this.bitSize % 8 !== 0) {
      throw new globalThis.Error(
        "BitArray.length does not support unaligned bit arrays"
      );
    }
    return this.rawBuffer.length;
  }
};
function bitArrayByteAt(buffer, bitOffset, index4) {
  if (bitOffset === 0) {
    return buffer[index4] ?? 0;
  } else {
    const a = buffer[index4] << bitOffset & 255;
    const b = buffer[index4 + 1] >> 8 - bitOffset;
    return a | b;
  }
}
var UtfCodepoint = class {
  constructor(value2) {
    this.value = value2;
  }
};
var isBitArrayDeprecationMessagePrinted = {};
function bitArrayPrintDeprecationWarning(name, message) {
  if (isBitArrayDeprecationMessagePrinted[name]) {
    return;
  }
  console.warn(
    `Deprecated BitArray.${name} property used in JavaScript FFI code. ${message}.`
  );
  isBitArrayDeprecationMessagePrinted[name] = true;
}
var Result = class _Result extends CustomType {
  // @internal
  static isResult(data) {
    return data instanceof _Result;
  }
};
var Ok = class extends Result {
  constructor(value2) {
    super();
    this[0] = value2;
  }
  // @internal
  isOk() {
    return true;
  }
};
var Error = class extends Result {
  constructor(detail) {
    super();
    this[0] = detail;
  }
  // @internal
  isOk() {
    return false;
  }
};
function isEqual(x, y) {
  let values4 = [x, y];
  while (values4.length) {
    let a = values4.pop();
    let b = values4.pop();
    if (a === b) continue;
    if (!isObject(a) || !isObject(b)) return false;
    let unequal = !structurallyCompatibleObjects(a, b) || unequalDates(a, b) || unequalBuffers(a, b) || unequalArrays(a, b) || unequalMaps(a, b) || unequalSets(a, b) || unequalRegExps(a, b);
    if (unequal) return false;
    const proto = Object.getPrototypeOf(a);
    if (proto !== null && typeof proto.equals === "function") {
      try {
        if (a.equals(b)) continue;
        else return false;
      } catch {
      }
    }
    let [keys2, get2] = getters(a);
    const ka = keys2(a);
    const kb = keys2(b);
    if (ka.length !== kb.length) return false;
    for (let k of ka) {
      values4.push(get2(a, k), get2(b, k));
    }
  }
  return true;
}
function getters(object4) {
  if (object4 instanceof Map) {
    return [(x) => x.keys(), (x, y) => x.get(y)];
  } else {
    let extra = object4 instanceof globalThis.Error ? ["message"] : [];
    return [(x) => [...extra, ...Object.keys(x)], (x, y) => x[y]];
  }
}
function unequalDates(a, b) {
  return a instanceof Date && (a > b || a < b);
}
function unequalBuffers(a, b) {
  return !(a instanceof BitArray) && a.buffer instanceof ArrayBuffer && a.BYTES_PER_ELEMENT && !(a.byteLength === b.byteLength && a.every((n, i) => n === b[i]));
}
function unequalArrays(a, b) {
  return Array.isArray(a) && a.length !== b.length;
}
function unequalMaps(a, b) {
  return a instanceof Map && a.size !== b.size;
}
function unequalSets(a, b) {
  return a instanceof Set && (a.size != b.size || [...a].some((e) => !b.has(e)));
}
function unequalRegExps(a, b) {
  return a instanceof RegExp && (a.source !== b.source || a.flags !== b.flags);
}
function isObject(a) {
  return typeof a === "object" && a !== null;
}
function structurallyCompatibleObjects(a, b) {
  if (typeof a !== "object" && typeof b !== "object" && (!a || !b))
    return false;
  let nonstructural = [Promise, WeakSet, WeakMap, Function];
  if (nonstructural.some((c) => a instanceof c)) return false;
  return a.constructor === b.constructor;
}
function divideFloat(a, b) {
  if (b === 0) {
    return 0;
  } else {
    return a / b;
  }
}
function makeError(variant, file, module, line, fn, message, extra) {
  let error = new globalThis.Error(message);
  error.gleam_error = variant;
  error.file = file;
  error.module = module;
  error.line = line;
  error.function = fn;
  error.fn = fn;
  for (let k in extra) error[k] = extra[k];
  return error;
}

// build/dev/javascript/gleam_stdlib/gleam/order.mjs
var Lt = class extends CustomType {
};
var Eq = class extends CustomType {
};
var Gt = class extends CustomType {
};
function reverse(orderer) {
  return (a, b) => {
    return orderer(b, a);
  };
}

// build/dev/javascript/gleam_stdlib/gleam/option.mjs
var Some = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var None = class extends CustomType {
};
function reverse_and_prepend(loop$prefix, loop$suffix) {
  while (true) {
    let prefix = loop$prefix;
    let suffix = loop$suffix;
    if (prefix instanceof Empty) {
      return suffix;
    } else {
      let first3 = prefix.head;
      let rest = prefix.tail;
      loop$prefix = rest;
      loop$suffix = prepend(first3, suffix);
    }
  }
}
function reverse2(list4) {
  return reverse_and_prepend(list4, toList([]));
}
function map(option, fun) {
  if (option instanceof Some) {
    let x = option[0];
    return new Some(fun(x));
  } else {
    return option;
  }
}
function values_loop(loop$list, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let acc = loop$acc;
    if (list4 instanceof Empty) {
      return reverse2(acc);
    } else {
      let $ = list4.head;
      if ($ instanceof Some) {
        let rest = list4.tail;
        let first3 = $[0];
        loop$list = rest;
        loop$acc = prepend(first3, acc);
      } else {
        let rest = list4.tail;
        loop$list = rest;
        loop$acc = acc;
      }
    }
  }
}
function values(options) {
  return values_loop(options, toList([]));
}

// build/dev/javascript/gleam_stdlib/dict.mjs
var referenceMap = /* @__PURE__ */ new WeakMap();
var tempDataView = /* @__PURE__ */ new DataView(
  /* @__PURE__ */ new ArrayBuffer(8)
);
var referenceUID = 0;
function hashByReference(o) {
  const known = referenceMap.get(o);
  if (known !== void 0) {
    return known;
  }
  const hash = referenceUID++;
  if (referenceUID === 2147483647) {
    referenceUID = 0;
  }
  referenceMap.set(o, hash);
  return hash;
}
function hashMerge(a, b) {
  return a ^ b + 2654435769 + (a << 6) + (a >> 2) | 0;
}
function hashString(s2) {
  let hash = 0;
  const len = s2.length;
  for (let i = 0; i < len; i++) {
    hash = Math.imul(31, hash) + s2.charCodeAt(i) | 0;
  }
  return hash;
}
function hashNumber(n) {
  tempDataView.setFloat64(0, n);
  const i = tempDataView.getInt32(0);
  const j = tempDataView.getInt32(4);
  return Math.imul(73244475, i >> 16 ^ i) ^ j;
}
function hashBigInt(n) {
  return hashString(n.toString());
}
function hashObject(o) {
  const proto = Object.getPrototypeOf(o);
  if (proto !== null && typeof proto.hashCode === "function") {
    try {
      const code = o.hashCode(o);
      if (typeof code === "number") {
        return code;
      }
    } catch {
    }
  }
  if (o instanceof Promise || o instanceof WeakSet || o instanceof WeakMap) {
    return hashByReference(o);
  }
  if (o instanceof Date) {
    return hashNumber(o.getTime());
  }
  let h = 0;
  if (o instanceof ArrayBuffer) {
    o = new Uint8Array(o);
  }
  if (Array.isArray(o) || o instanceof Uint8Array) {
    for (let i = 0; i < o.length; i++) {
      h = Math.imul(31, h) + getHash(o[i]) | 0;
    }
  } else if (o instanceof Set) {
    o.forEach((v) => {
      h = h + getHash(v) | 0;
    });
  } else if (o instanceof Map) {
    o.forEach((v, k) => {
      h = h + hashMerge(getHash(v), getHash(k)) | 0;
    });
  } else {
    const keys2 = Object.keys(o);
    for (let i = 0; i < keys2.length; i++) {
      const k = keys2[i];
      const v = o[k];
      h = h + hashMerge(getHash(v), hashString(k)) | 0;
    }
  }
  return h;
}
function getHash(u2) {
  if (u2 === null) return 1108378658;
  if (u2 === void 0) return 1108378659;
  if (u2 === true) return 1108378657;
  if (u2 === false) return 1108378656;
  switch (typeof u2) {
    case "number":
      return hashNumber(u2);
    case "string":
      return hashString(u2);
    case "bigint":
      return hashBigInt(u2);
    case "object":
      return hashObject(u2);
    case "symbol":
      return hashByReference(u2);
    case "function":
      return hashByReference(u2);
    default:
      return 0;
  }
}
var SHIFT = 5;
var BUCKET_SIZE = Math.pow(2, SHIFT);
var MASK = BUCKET_SIZE - 1;
var MAX_INDEX_NODE = BUCKET_SIZE / 2;
var MIN_ARRAY_NODE = BUCKET_SIZE / 4;
var ENTRY = 0;
var ARRAY_NODE = 1;
var INDEX_NODE = 2;
var COLLISION_NODE = 3;
var EMPTY = {
  type: INDEX_NODE,
  bitmap: 0,
  array: []
};
function mask(hash, shift) {
  return hash >>> shift & MASK;
}
function bitpos(hash, shift) {
  return 1 << mask(hash, shift);
}
function bitcount(x) {
  x -= x >> 1 & 1431655765;
  x = (x & 858993459) + (x >> 2 & 858993459);
  x = x + (x >> 4) & 252645135;
  x += x >> 8;
  x += x >> 16;
  return x & 127;
}
function index(bitmap, bit) {
  return bitcount(bitmap & bit - 1);
}
function cloneAndSet(arr, at2, val) {
  const len = arr.length;
  const out = new Array(len);
  for (let i = 0; i < len; ++i) {
    out[i] = arr[i];
  }
  out[at2] = val;
  return out;
}
function spliceIn(arr, at2, val) {
  const len = arr.length;
  const out = new Array(len + 1);
  let i = 0;
  let g = 0;
  while (i < at2) {
    out[g++] = arr[i++];
  }
  out[g++] = val;
  while (i < len) {
    out[g++] = arr[i++];
  }
  return out;
}
function spliceOut(arr, at2) {
  const len = arr.length;
  const out = new Array(len - 1);
  let i = 0;
  let g = 0;
  while (i < at2) {
    out[g++] = arr[i++];
  }
  ++i;
  while (i < len) {
    out[g++] = arr[i++];
  }
  return out;
}
function createNode(shift, key1, val1, key2hash, key2, val2) {
  const key1hash = getHash(key1);
  if (key1hash === key2hash) {
    return {
      type: COLLISION_NODE,
      hash: key1hash,
      array: [
        { type: ENTRY, k: key1, v: val1 },
        { type: ENTRY, k: key2, v: val2 }
      ]
    };
  }
  const addedLeaf = { val: false };
  return assoc(
    assocIndex(EMPTY, shift, key1hash, key1, val1, addedLeaf),
    shift,
    key2hash,
    key2,
    val2,
    addedLeaf
  );
}
function assoc(root3, shift, hash, key2, val, addedLeaf) {
  switch (root3.type) {
    case ARRAY_NODE:
      return assocArray(root3, shift, hash, key2, val, addedLeaf);
    case INDEX_NODE:
      return assocIndex(root3, shift, hash, key2, val, addedLeaf);
    case COLLISION_NODE:
      return assocCollision(root3, shift, hash, key2, val, addedLeaf);
  }
}
function assocArray(root3, shift, hash, key2, val, addedLeaf) {
  const idx = mask(hash, shift);
  const node = root3.array[idx];
  if (node === void 0) {
    addedLeaf.val = true;
    return {
      type: ARRAY_NODE,
      size: root3.size + 1,
      array: cloneAndSet(root3.array, idx, { type: ENTRY, k: key2, v: val })
    };
  }
  if (node.type === ENTRY) {
    if (isEqual(key2, node.k)) {
      if (val === node.v) {
        return root3;
      }
      return {
        type: ARRAY_NODE,
        size: root3.size,
        array: cloneAndSet(root3.array, idx, {
          type: ENTRY,
          k: key2,
          v: val
        })
      };
    }
    addedLeaf.val = true;
    return {
      type: ARRAY_NODE,
      size: root3.size,
      array: cloneAndSet(
        root3.array,
        idx,
        createNode(shift + SHIFT, node.k, node.v, hash, key2, val)
      )
    };
  }
  const n = assoc(node, shift + SHIFT, hash, key2, val, addedLeaf);
  if (n === node) {
    return root3;
  }
  return {
    type: ARRAY_NODE,
    size: root3.size,
    array: cloneAndSet(root3.array, idx, n)
  };
}
function assocIndex(root3, shift, hash, key2, val, addedLeaf) {
  const bit = bitpos(hash, shift);
  const idx = index(root3.bitmap, bit);
  if ((root3.bitmap & bit) !== 0) {
    const node = root3.array[idx];
    if (node.type !== ENTRY) {
      const n = assoc(node, shift + SHIFT, hash, key2, val, addedLeaf);
      if (n === node) {
        return root3;
      }
      return {
        type: INDEX_NODE,
        bitmap: root3.bitmap,
        array: cloneAndSet(root3.array, idx, n)
      };
    }
    const nodeKey = node.k;
    if (isEqual(key2, nodeKey)) {
      if (val === node.v) {
        return root3;
      }
      return {
        type: INDEX_NODE,
        bitmap: root3.bitmap,
        array: cloneAndSet(root3.array, idx, {
          type: ENTRY,
          k: key2,
          v: val
        })
      };
    }
    addedLeaf.val = true;
    return {
      type: INDEX_NODE,
      bitmap: root3.bitmap,
      array: cloneAndSet(
        root3.array,
        idx,
        createNode(shift + SHIFT, nodeKey, node.v, hash, key2, val)
      )
    };
  } else {
    const n = root3.array.length;
    if (n >= MAX_INDEX_NODE) {
      const nodes = new Array(32);
      const jdx = mask(hash, shift);
      nodes[jdx] = assocIndex(EMPTY, shift + SHIFT, hash, key2, val, addedLeaf);
      let j = 0;
      let bitmap = root3.bitmap;
      for (let i = 0; i < 32; i++) {
        if ((bitmap & 1) !== 0) {
          const node = root3.array[j++];
          nodes[i] = node;
        }
        bitmap = bitmap >>> 1;
      }
      return {
        type: ARRAY_NODE,
        size: n + 1,
        array: nodes
      };
    } else {
      const newArray = spliceIn(root3.array, idx, {
        type: ENTRY,
        k: key2,
        v: val
      });
      addedLeaf.val = true;
      return {
        type: INDEX_NODE,
        bitmap: root3.bitmap | bit,
        array: newArray
      };
    }
  }
}
function assocCollision(root3, shift, hash, key2, val, addedLeaf) {
  if (hash === root3.hash) {
    const idx = collisionIndexOf(root3, key2);
    if (idx !== -1) {
      const entry = root3.array[idx];
      if (entry.v === val) {
        return root3;
      }
      return {
        type: COLLISION_NODE,
        hash,
        array: cloneAndSet(root3.array, idx, { type: ENTRY, k: key2, v: val })
      };
    }
    const size3 = root3.array.length;
    addedLeaf.val = true;
    return {
      type: COLLISION_NODE,
      hash,
      array: cloneAndSet(root3.array, size3, { type: ENTRY, k: key2, v: val })
    };
  }
  return assoc(
    {
      type: INDEX_NODE,
      bitmap: bitpos(root3.hash, shift),
      array: [root3]
    },
    shift,
    hash,
    key2,
    val,
    addedLeaf
  );
}
function collisionIndexOf(root3, key2) {
  const size3 = root3.array.length;
  for (let i = 0; i < size3; i++) {
    if (isEqual(key2, root3.array[i].k)) {
      return i;
    }
  }
  return -1;
}
function find(root3, shift, hash, key2) {
  switch (root3.type) {
    case ARRAY_NODE:
      return findArray(root3, shift, hash, key2);
    case INDEX_NODE:
      return findIndex(root3, shift, hash, key2);
    case COLLISION_NODE:
      return findCollision(root3, key2);
  }
}
function findArray(root3, shift, hash, key2) {
  const idx = mask(hash, shift);
  const node = root3.array[idx];
  if (node === void 0) {
    return void 0;
  }
  if (node.type !== ENTRY) {
    return find(node, shift + SHIFT, hash, key2);
  }
  if (isEqual(key2, node.k)) {
    return node;
  }
  return void 0;
}
function findIndex(root3, shift, hash, key2) {
  const bit = bitpos(hash, shift);
  if ((root3.bitmap & bit) === 0) {
    return void 0;
  }
  const idx = index(root3.bitmap, bit);
  const node = root3.array[idx];
  if (node.type !== ENTRY) {
    return find(node, shift + SHIFT, hash, key2);
  }
  if (isEqual(key2, node.k)) {
    return node;
  }
  return void 0;
}
function findCollision(root3, key2) {
  const idx = collisionIndexOf(root3, key2);
  if (idx < 0) {
    return void 0;
  }
  return root3.array[idx];
}
function without(root3, shift, hash, key2) {
  switch (root3.type) {
    case ARRAY_NODE:
      return withoutArray(root3, shift, hash, key2);
    case INDEX_NODE:
      return withoutIndex(root3, shift, hash, key2);
    case COLLISION_NODE:
      return withoutCollision(root3, key2);
  }
}
function withoutArray(root3, shift, hash, key2) {
  const idx = mask(hash, shift);
  const node = root3.array[idx];
  if (node === void 0) {
    return root3;
  }
  let n = void 0;
  if (node.type === ENTRY) {
    if (!isEqual(node.k, key2)) {
      return root3;
    }
  } else {
    n = without(node, shift + SHIFT, hash, key2);
    if (n === node) {
      return root3;
    }
  }
  if (n === void 0) {
    if (root3.size <= MIN_ARRAY_NODE) {
      const arr = root3.array;
      const out = new Array(root3.size - 1);
      let i = 0;
      let j = 0;
      let bitmap = 0;
      while (i < idx) {
        const nv = arr[i];
        if (nv !== void 0) {
          out[j] = nv;
          bitmap |= 1 << i;
          ++j;
        }
        ++i;
      }
      ++i;
      while (i < arr.length) {
        const nv = arr[i];
        if (nv !== void 0) {
          out[j] = nv;
          bitmap |= 1 << i;
          ++j;
        }
        ++i;
      }
      return {
        type: INDEX_NODE,
        bitmap,
        array: out
      };
    }
    return {
      type: ARRAY_NODE,
      size: root3.size - 1,
      array: cloneAndSet(root3.array, idx, n)
    };
  }
  return {
    type: ARRAY_NODE,
    size: root3.size,
    array: cloneAndSet(root3.array, idx, n)
  };
}
function withoutIndex(root3, shift, hash, key2) {
  const bit = bitpos(hash, shift);
  if ((root3.bitmap & bit) === 0) {
    return root3;
  }
  const idx = index(root3.bitmap, bit);
  const node = root3.array[idx];
  if (node.type !== ENTRY) {
    const n = without(node, shift + SHIFT, hash, key2);
    if (n === node) {
      return root3;
    }
    if (n !== void 0) {
      return {
        type: INDEX_NODE,
        bitmap: root3.bitmap,
        array: cloneAndSet(root3.array, idx, n)
      };
    }
    if (root3.bitmap === bit) {
      return void 0;
    }
    return {
      type: INDEX_NODE,
      bitmap: root3.bitmap ^ bit,
      array: spliceOut(root3.array, idx)
    };
  }
  if (isEqual(key2, node.k)) {
    if (root3.bitmap === bit) {
      return void 0;
    }
    return {
      type: INDEX_NODE,
      bitmap: root3.bitmap ^ bit,
      array: spliceOut(root3.array, idx)
    };
  }
  return root3;
}
function withoutCollision(root3, key2) {
  const idx = collisionIndexOf(root3, key2);
  if (idx < 0) {
    return root3;
  }
  if (root3.array.length === 1) {
    return void 0;
  }
  return {
    type: COLLISION_NODE,
    hash: root3.hash,
    array: spliceOut(root3.array, idx)
  };
}
function forEach(root3, fn) {
  if (root3 === void 0) {
    return;
  }
  const items = root3.array;
  const size3 = items.length;
  for (let i = 0; i < size3; i++) {
    const item = items[i];
    if (item === void 0) {
      continue;
    }
    if (item.type === ENTRY) {
      fn(item.v, item.k);
      continue;
    }
    forEach(item, fn);
  }
}
var Dict = class _Dict {
  /**
   * @template V
   * @param {Record<string,V>} o
   * @returns {Dict<string,V>}
   */
  static fromObject(o) {
    const keys2 = Object.keys(o);
    let m = _Dict.new();
    for (let i = 0; i < keys2.length; i++) {
      const k = keys2[i];
      m = m.set(k, o[k]);
    }
    return m;
  }
  /**
   * @template K,V
   * @param {Map<K,V>} o
   * @returns {Dict<K,V>}
   */
  static fromMap(o) {
    let m = _Dict.new();
    o.forEach((v, k) => {
      m = m.set(k, v);
    });
    return m;
  }
  static new() {
    return new _Dict(void 0, 0);
  }
  /**
   * @param {undefined | Node<K,V>} root
   * @param {number} size
   */
  constructor(root3, size3) {
    this.root = root3;
    this.size = size3;
  }
  /**
   * @template NotFound
   * @param {K} key
   * @param {NotFound} notFound
   * @returns {NotFound | V}
   */
  get(key2, notFound) {
    if (this.root === void 0) {
      return notFound;
    }
    const found = find(this.root, 0, getHash(key2), key2);
    if (found === void 0) {
      return notFound;
    }
    return found.v;
  }
  /**
   * @param {K} key
   * @param {V} val
   * @returns {Dict<K,V>}
   */
  set(key2, val) {
    const addedLeaf = { val: false };
    const root3 = this.root === void 0 ? EMPTY : this.root;
    const newRoot = assoc(root3, 0, getHash(key2), key2, val, addedLeaf);
    if (newRoot === this.root) {
      return this;
    }
    return new _Dict(newRoot, addedLeaf.val ? this.size + 1 : this.size);
  }
  /**
   * @param {K} key
   * @returns {Dict<K,V>}
   */
  delete(key2) {
    if (this.root === void 0) {
      return this;
    }
    const newRoot = without(this.root, 0, getHash(key2), key2);
    if (newRoot === this.root) {
      return this;
    }
    if (newRoot === void 0) {
      return _Dict.new();
    }
    return new _Dict(newRoot, this.size - 1);
  }
  /**
   * @param {K} key
   * @returns {boolean}
   */
  has(key2) {
    if (this.root === void 0) {
      return false;
    }
    return find(this.root, 0, getHash(key2), key2) !== void 0;
  }
  /**
   * @returns {[K,V][]}
   */
  entries() {
    if (this.root === void 0) {
      return [];
    }
    const result = [];
    this.forEach((v, k) => result.push([k, v]));
    return result;
  }
  /**
   *
   * @param {(val:V,key:K)=>void} fn
   */
  forEach(fn) {
    forEach(this.root, fn);
  }
  hashCode() {
    let h = 0;
    this.forEach((v, k) => {
      h = h + hashMerge(getHash(v), getHash(k)) | 0;
    });
    return h;
  }
  /**
   * @param {unknown} o
   * @returns {boolean}
   */
  equals(o) {
    if (!(o instanceof _Dict) || this.size !== o.size) {
      return false;
    }
    try {
      this.forEach((v, k) => {
        if (!isEqual(o.get(k, !v), v)) {
          throw unequalDictSymbol;
        }
      });
      return true;
    } catch (e) {
      if (e === unequalDictSymbol) {
        return false;
      }
      throw e;
    }
  }
};
var unequalDictSymbol = /* @__PURE__ */ Symbol();

// build/dev/javascript/gleam_stdlib/gleam/dict.mjs
function insert(dict3, key2, value2) {
  return map_insert(key2, value2, dict3);
}

// build/dev/javascript/gleam_stdlib/gleam/list.mjs
var Ascending = class extends CustomType {
};
var Descending = class extends CustomType {
};
function reverse_and_prepend2(loop$prefix, loop$suffix) {
  while (true) {
    let prefix = loop$prefix;
    let suffix = loop$suffix;
    if (prefix instanceof Empty) {
      return suffix;
    } else {
      let first$1 = prefix.head;
      let rest$1 = prefix.tail;
      loop$prefix = rest$1;
      loop$suffix = prepend(first$1, suffix);
    }
  }
}
function reverse3(list4) {
  return reverse_and_prepend2(list4, toList([]));
}
function is_empty2(list4) {
  return isEqual(list4, toList([]));
}
function filter_loop(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list4 instanceof Empty) {
      return reverse3(acc);
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      let _block;
      let $ = fun(first$1);
      if ($) {
        _block = prepend(first$1, acc);
      } else {
        _block = acc;
      }
      let new_acc = _block;
      loop$list = rest$1;
      loop$fun = fun;
      loop$acc = new_acc;
    }
  }
}
function filter(list4, predicate) {
  return filter_loop(list4, predicate, toList([]));
}
function map_loop(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list4 instanceof Empty) {
      return reverse3(acc);
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      loop$list = rest$1;
      loop$fun = fun;
      loop$acc = prepend(fun(first$1), acc);
    }
  }
}
function map2(list4, fun) {
  return map_loop(list4, fun, toList([]));
}
function append_loop(loop$first, loop$second) {
  while (true) {
    let first3 = loop$first;
    let second2 = loop$second;
    if (first3 instanceof Empty) {
      return second2;
    } else {
      let first$1 = first3.head;
      let rest$1 = first3.tail;
      loop$first = rest$1;
      loop$second = prepend(first$1, second2);
    }
  }
}
function append(first3, second2) {
  return append_loop(reverse3(first3), second2);
}
function flatten_loop(loop$lists, loop$acc) {
  while (true) {
    let lists = loop$lists;
    let acc = loop$acc;
    if (lists instanceof Empty) {
      return reverse3(acc);
    } else {
      let list4 = lists.head;
      let further_lists = lists.tail;
      loop$lists = further_lists;
      loop$acc = reverse_and_prepend2(list4, acc);
    }
  }
}
function flatten(lists) {
  return flatten_loop(lists, toList([]));
}
function flat_map(list4, fun) {
  return flatten(map2(list4, fun));
}
function fold(loop$list, loop$initial, loop$fun) {
  while (true) {
    let list4 = loop$list;
    let initial = loop$initial;
    let fun = loop$fun;
    if (list4 instanceof Empty) {
      return initial;
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      loop$list = rest$1;
      loop$initial = fun(initial, first$1);
      loop$fun = fun;
    }
  }
}
function fold_right(list4, initial, fun) {
  if (list4 instanceof Empty) {
    return initial;
  } else {
    let first$1 = list4.head;
    let rest$1 = list4.tail;
    return fun(fold_right(rest$1, initial, fun), first$1);
  }
}
function any(loop$list, loop$predicate) {
  while (true) {
    let list4 = loop$list;
    let predicate = loop$predicate;
    if (list4 instanceof Empty) {
      return false;
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      let $ = predicate(first$1);
      if ($) {
        return $;
      } else {
        loop$list = rest$1;
        loop$predicate = predicate;
      }
    }
  }
}
function sequences(loop$list, loop$compare, loop$growing, loop$direction, loop$prev, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let compare4 = loop$compare;
    let growing = loop$growing;
    let direction = loop$direction;
    let prev = loop$prev;
    let acc = loop$acc;
    let growing$1 = prepend(prev, growing);
    if (list4 instanceof Empty) {
      if (direction instanceof Ascending) {
        return prepend(reverse3(growing$1), acc);
      } else {
        return prepend(growing$1, acc);
      }
    } else {
      let new$1 = list4.head;
      let rest$1 = list4.tail;
      let $ = compare4(prev, new$1);
      if (direction instanceof Ascending) {
        if ($ instanceof Lt) {
          loop$list = rest$1;
          loop$compare = compare4;
          loop$growing = growing$1;
          loop$direction = direction;
          loop$prev = new$1;
          loop$acc = acc;
        } else if ($ instanceof Eq) {
          loop$list = rest$1;
          loop$compare = compare4;
          loop$growing = growing$1;
          loop$direction = direction;
          loop$prev = new$1;
          loop$acc = acc;
        } else {
          let _block;
          if (direction instanceof Ascending) {
            _block = prepend(reverse3(growing$1), acc);
          } else {
            _block = prepend(growing$1, acc);
          }
          let acc$1 = _block;
          if (rest$1 instanceof Empty) {
            return prepend(toList([new$1]), acc$1);
          } else {
            let next = rest$1.head;
            let rest$2 = rest$1.tail;
            let _block$1;
            let $1 = compare4(new$1, next);
            if ($1 instanceof Lt) {
              _block$1 = new Ascending();
            } else if ($1 instanceof Eq) {
              _block$1 = new Ascending();
            } else {
              _block$1 = new Descending();
            }
            let direction$1 = _block$1;
            loop$list = rest$2;
            loop$compare = compare4;
            loop$growing = toList([new$1]);
            loop$direction = direction$1;
            loop$prev = next;
            loop$acc = acc$1;
          }
        }
      } else if ($ instanceof Lt) {
        let _block;
        if (direction instanceof Ascending) {
          _block = prepend(reverse3(growing$1), acc);
        } else {
          _block = prepend(growing$1, acc);
        }
        let acc$1 = _block;
        if (rest$1 instanceof Empty) {
          return prepend(toList([new$1]), acc$1);
        } else {
          let next = rest$1.head;
          let rest$2 = rest$1.tail;
          let _block$1;
          let $1 = compare4(new$1, next);
          if ($1 instanceof Lt) {
            _block$1 = new Ascending();
          } else if ($1 instanceof Eq) {
            _block$1 = new Ascending();
          } else {
            _block$1 = new Descending();
          }
          let direction$1 = _block$1;
          loop$list = rest$2;
          loop$compare = compare4;
          loop$growing = toList([new$1]);
          loop$direction = direction$1;
          loop$prev = next;
          loop$acc = acc$1;
        }
      } else if ($ instanceof Eq) {
        let _block;
        if (direction instanceof Ascending) {
          _block = prepend(reverse3(growing$1), acc);
        } else {
          _block = prepend(growing$1, acc);
        }
        let acc$1 = _block;
        if (rest$1 instanceof Empty) {
          return prepend(toList([new$1]), acc$1);
        } else {
          let next = rest$1.head;
          let rest$2 = rest$1.tail;
          let _block$1;
          let $1 = compare4(new$1, next);
          if ($1 instanceof Lt) {
            _block$1 = new Ascending();
          } else if ($1 instanceof Eq) {
            _block$1 = new Ascending();
          } else {
            _block$1 = new Descending();
          }
          let direction$1 = _block$1;
          loop$list = rest$2;
          loop$compare = compare4;
          loop$growing = toList([new$1]);
          loop$direction = direction$1;
          loop$prev = next;
          loop$acc = acc$1;
        }
      } else {
        loop$list = rest$1;
        loop$compare = compare4;
        loop$growing = growing$1;
        loop$direction = direction;
        loop$prev = new$1;
        loop$acc = acc;
      }
    }
  }
}
function merge_ascendings(loop$list1, loop$list2, loop$compare, loop$acc) {
  while (true) {
    let list1 = loop$list1;
    let list22 = loop$list2;
    let compare4 = loop$compare;
    let acc = loop$acc;
    if (list1 instanceof Empty) {
      let list4 = list22;
      return reverse_and_prepend2(list4, acc);
    } else if (list22 instanceof Empty) {
      let list4 = list1;
      return reverse_and_prepend2(list4, acc);
    } else {
      let first1 = list1.head;
      let rest1 = list1.tail;
      let first22 = list22.head;
      let rest2 = list22.tail;
      let $ = compare4(first1, first22);
      if ($ instanceof Lt) {
        loop$list1 = rest1;
        loop$list2 = list22;
        loop$compare = compare4;
        loop$acc = prepend(first1, acc);
      } else if ($ instanceof Eq) {
        loop$list1 = list1;
        loop$list2 = rest2;
        loop$compare = compare4;
        loop$acc = prepend(first22, acc);
      } else {
        loop$list1 = list1;
        loop$list2 = rest2;
        loop$compare = compare4;
        loop$acc = prepend(first22, acc);
      }
    }
  }
}
function merge_ascending_pairs(loop$sequences, loop$compare, loop$acc) {
  while (true) {
    let sequences2 = loop$sequences;
    let compare4 = loop$compare;
    let acc = loop$acc;
    if (sequences2 instanceof Empty) {
      return reverse3(acc);
    } else {
      let $ = sequences2.tail;
      if ($ instanceof Empty) {
        let sequence = sequences2.head;
        return reverse3(prepend(reverse3(sequence), acc));
      } else {
        let ascending1 = sequences2.head;
        let ascending2 = $.head;
        let rest$1 = $.tail;
        let descending = merge_ascendings(
          ascending1,
          ascending2,
          compare4,
          toList([])
        );
        loop$sequences = rest$1;
        loop$compare = compare4;
        loop$acc = prepend(descending, acc);
      }
    }
  }
}
function merge_descendings(loop$list1, loop$list2, loop$compare, loop$acc) {
  while (true) {
    let list1 = loop$list1;
    let list22 = loop$list2;
    let compare4 = loop$compare;
    let acc = loop$acc;
    if (list1 instanceof Empty) {
      let list4 = list22;
      return reverse_and_prepend2(list4, acc);
    } else if (list22 instanceof Empty) {
      let list4 = list1;
      return reverse_and_prepend2(list4, acc);
    } else {
      let first1 = list1.head;
      let rest1 = list1.tail;
      let first22 = list22.head;
      let rest2 = list22.tail;
      let $ = compare4(first1, first22);
      if ($ instanceof Lt) {
        loop$list1 = list1;
        loop$list2 = rest2;
        loop$compare = compare4;
        loop$acc = prepend(first22, acc);
      } else if ($ instanceof Eq) {
        loop$list1 = rest1;
        loop$list2 = list22;
        loop$compare = compare4;
        loop$acc = prepend(first1, acc);
      } else {
        loop$list1 = rest1;
        loop$list2 = list22;
        loop$compare = compare4;
        loop$acc = prepend(first1, acc);
      }
    }
  }
}
function merge_descending_pairs(loop$sequences, loop$compare, loop$acc) {
  while (true) {
    let sequences2 = loop$sequences;
    let compare4 = loop$compare;
    let acc = loop$acc;
    if (sequences2 instanceof Empty) {
      return reverse3(acc);
    } else {
      let $ = sequences2.tail;
      if ($ instanceof Empty) {
        let sequence = sequences2.head;
        return reverse3(prepend(reverse3(sequence), acc));
      } else {
        let descending1 = sequences2.head;
        let descending2 = $.head;
        let rest$1 = $.tail;
        let ascending = merge_descendings(
          descending1,
          descending2,
          compare4,
          toList([])
        );
        loop$sequences = rest$1;
        loop$compare = compare4;
        loop$acc = prepend(ascending, acc);
      }
    }
  }
}
function merge_all(loop$sequences, loop$direction, loop$compare) {
  while (true) {
    let sequences2 = loop$sequences;
    let direction = loop$direction;
    let compare4 = loop$compare;
    if (sequences2 instanceof Empty) {
      return sequences2;
    } else if (direction instanceof Ascending) {
      let $ = sequences2.tail;
      if ($ instanceof Empty) {
        let sequence = sequences2.head;
        return sequence;
      } else {
        let sequences$1 = merge_ascending_pairs(sequences2, compare4, toList([]));
        loop$sequences = sequences$1;
        loop$direction = new Descending();
        loop$compare = compare4;
      }
    } else {
      let $ = sequences2.tail;
      if ($ instanceof Empty) {
        let sequence = sequences2.head;
        return reverse3(sequence);
      } else {
        let sequences$1 = merge_descending_pairs(sequences2, compare4, toList([]));
        loop$sequences = sequences$1;
        loop$direction = new Ascending();
        loop$compare = compare4;
      }
    }
  }
}
function sort(list4, compare4) {
  if (list4 instanceof Empty) {
    return list4;
  } else {
    let $ = list4.tail;
    if ($ instanceof Empty) {
      return list4;
    } else {
      let x = list4.head;
      let y = $.head;
      let rest$1 = $.tail;
      let _block;
      let $1 = compare4(x, y);
      if ($1 instanceof Lt) {
        _block = new Ascending();
      } else if ($1 instanceof Eq) {
        _block = new Ascending();
      } else {
        _block = new Descending();
      }
      let direction = _block;
      let sequences$1 = sequences(
        rest$1,
        compare4,
        toList([x]),
        direction,
        y,
        toList([])
      );
      return merge_all(sequences$1, new Ascending(), compare4);
    }
  }
}
function range_loop(loop$start, loop$stop, loop$acc) {
  while (true) {
    let start4 = loop$start;
    let stop = loop$stop;
    let acc = loop$acc;
    let $ = compare2(start4, stop);
    if ($ instanceof Lt) {
      loop$start = start4;
      loop$stop = stop - 1;
      loop$acc = prepend(stop, acc);
    } else if ($ instanceof Eq) {
      return prepend(stop, acc);
    } else {
      loop$start = start4;
      loop$stop = stop + 1;
      loop$acc = prepend(stop, acc);
    }
  }
}
function range(start4, stop) {
  return range_loop(start4, stop, toList([]));
}
function max_loop(loop$list, loop$compare, loop$max) {
  while (true) {
    let list4 = loop$list;
    let compare4 = loop$compare;
    let max4 = loop$max;
    if (list4 instanceof Empty) {
      return max4;
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      let $ = compare4(first$1, max4);
      if ($ instanceof Lt) {
        loop$list = rest$1;
        loop$compare = compare4;
        loop$max = max4;
      } else if ($ instanceof Eq) {
        loop$list = rest$1;
        loop$compare = compare4;
        loop$max = max4;
      } else {
        loop$list = rest$1;
        loop$compare = compare4;
        loop$max = first$1;
      }
    }
  }
}
function max(list4, compare4) {
  if (list4 instanceof Empty) {
    return new Error(void 0);
  } else {
    let first$1 = list4.head;
    let rest$1 = list4.tail;
    return new Ok(max_loop(rest$1, compare4, first$1));
  }
}

// build/dev/javascript/gleam_stdlib/gleam/string.mjs
function concat_loop(loop$strings, loop$accumulator) {
  while (true) {
    let strings = loop$strings;
    let accumulator = loop$accumulator;
    if (strings instanceof Empty) {
      return accumulator;
    } else {
      let string5 = strings.head;
      let strings$1 = strings.tail;
      loop$strings = strings$1;
      loop$accumulator = accumulator + string5;
    }
  }
}
function concat2(strings) {
  return concat_loop(strings, "");
}
function join_loop(loop$strings, loop$separator, loop$accumulator) {
  while (true) {
    let strings = loop$strings;
    let separator = loop$separator;
    let accumulator = loop$accumulator;
    if (strings instanceof Empty) {
      return accumulator;
    } else {
      let string5 = strings.head;
      let strings$1 = strings.tail;
      loop$strings = strings$1;
      loop$separator = separator;
      loop$accumulator = accumulator + separator + string5;
    }
  }
}
function join(strings, separator) {
  if (strings instanceof Empty) {
    return "";
  } else {
    let first$1 = strings.head;
    let rest = strings.tail;
    return join_loop(rest, separator, first$1);
  }
}
function split2(x, substring) {
  if (substring === "") {
    return graphemes(x);
  } else {
    let _pipe = x;
    let _pipe$1 = identity(_pipe);
    let _pipe$2 = split(_pipe$1, substring);
    return map2(_pipe$2, identity);
  }
}

// build/dev/javascript/gleam_stdlib/gleam/dynamic/decode.mjs
var DecodeError = class extends CustomType {
  constructor(expected, found, path) {
    super();
    this.expected = expected;
    this.found = found;
    this.path = path;
  }
};
var Decoder = class extends CustomType {
  constructor(function$) {
    super();
    this.function = function$;
  }
};
function run(data, decoder) {
  let $ = decoder.function(data);
  let maybe_invalid_data;
  let errors;
  maybe_invalid_data = $[0];
  errors = $[1];
  if (errors instanceof Empty) {
    return new Ok(maybe_invalid_data);
  } else {
    return new Error(errors);
  }
}
function success(data) {
  return new Decoder((_) => {
    return [data, toList([])];
  });
}
function map3(decoder, transformer) {
  return new Decoder(
    (d) => {
      let $ = decoder.function(d);
      let data;
      let errors;
      data = $[0];
      errors = $[1];
      return [transformer(data), errors];
    }
  );
}
function then$(decoder, next) {
  return new Decoder(
    (dynamic_data) => {
      let $ = decoder.function(dynamic_data);
      let data;
      let errors;
      data = $[0];
      errors = $[1];
      let decoder$1 = next(data);
      let $1 = decoder$1.function(dynamic_data);
      let layer;
      let data$1;
      layer = $1;
      data$1 = $1[0];
      if (errors instanceof Empty) {
        return layer;
      } else {
        return [data$1, errors];
      }
    }
  );
}
function run_decoders(loop$data, loop$failure, loop$decoders) {
  while (true) {
    let data = loop$data;
    let failure2 = loop$failure;
    let decoders = loop$decoders;
    if (decoders instanceof Empty) {
      return failure2;
    } else {
      let decoder = decoders.head;
      let decoders$1 = decoders.tail;
      let $ = decoder.function(data);
      let layer;
      let errors;
      layer = $;
      errors = $[1];
      if (errors instanceof Empty) {
        return layer;
      } else {
        loop$data = data;
        loop$failure = failure2;
        loop$decoders = decoders$1;
      }
    }
  }
}
function one_of(first3, alternatives) {
  return new Decoder(
    (dynamic_data) => {
      let $ = first3.function(dynamic_data);
      let layer;
      let errors;
      layer = $;
      errors = $[1];
      if (errors instanceof Empty) {
        return layer;
      } else {
        return run_decoders(dynamic_data, layer, alternatives);
      }
    }
  );
}
function decode_error(expected, found) {
  return toList([
    new DecodeError(expected, classify_dynamic(found), toList([]))
  ]);
}
function run_dynamic_function(data, name, f) {
  let $ = f(data);
  if ($ instanceof Ok) {
    let data$1 = $[0];
    return [data$1, toList([])];
  } else {
    let zero = $[0];
    return [
      zero,
      toList([new DecodeError(name, classify_dynamic(data), toList([]))])
    ];
  }
}
function decode_int(data) {
  return run_dynamic_function(data, "Int", int);
}
function failure(zero, expected) {
  return new Decoder((d) => {
    return [zero, decode_error(expected, d)];
  });
}
var int2 = /* @__PURE__ */ new Decoder(decode_int);
function decode_string(data) {
  return run_dynamic_function(data, "String", string);
}
var string2 = /* @__PURE__ */ new Decoder(decode_string);
function push_path(layer, path) {
  let decoder = one_of(
    string2,
    toList([
      (() => {
        let _pipe = int2;
        return map3(_pipe, to_string);
      })()
    ])
  );
  let path$1 = map2(
    path,
    (key2) => {
      let key$1 = identity(key2);
      let $ = run(key$1, decoder);
      if ($ instanceof Ok) {
        let key$2 = $[0];
        return key$2;
      } else {
        return "<" + classify_dynamic(key$1) + ">";
      }
    }
  );
  let errors = map2(
    layer[1],
    (error) => {
      return new DecodeError(
        error.expected,
        error.found,
        append(path$1, error.path)
      );
    }
  );
  return [layer[0], errors];
}
function index3(loop$path, loop$position, loop$inner, loop$data, loop$handle_miss) {
  while (true) {
    let path = loop$path;
    let position = loop$position;
    let inner = loop$inner;
    let data = loop$data;
    let handle_miss = loop$handle_miss;
    if (path instanceof Empty) {
      let _pipe = inner(data);
      return push_path(_pipe, reverse3(position));
    } else {
      let key2 = path.head;
      let path$1 = path.tail;
      let $ = index2(data, key2);
      if ($ instanceof Ok) {
        let $1 = $[0];
        if ($1 instanceof Some) {
          let data$1 = $1[0];
          loop$path = path$1;
          loop$position = prepend(key2, position);
          loop$inner = inner;
          loop$data = data$1;
          loop$handle_miss = handle_miss;
        } else {
          return handle_miss(data, prepend(key2, position));
        }
      } else {
        let kind = $[0];
        let $1 = inner(data);
        let default$;
        default$ = $1[0];
        let _pipe = [
          default$,
          toList([new DecodeError(kind, classify_dynamic(data), toList([]))])
        ];
        return push_path(_pipe, reverse3(position));
      }
    }
  }
}
function at(path, inner) {
  return new Decoder(
    (data) => {
      return index3(
        path,
        toList([]),
        inner.function,
        data,
        (data2, position) => {
          let $ = inner.function(data2);
          let default$;
          default$ = $[0];
          let _pipe = [
            default$,
            toList([new DecodeError("Field", "Nothing", toList([]))])
          ];
          return push_path(_pipe, reverse3(position));
        }
      );
    }
  );
}

// build/dev/javascript/gleam_stdlib/gleam_stdlib.mjs
var Nil = void 0;
var NOT_FOUND = {};
function identity(x) {
  return x;
}
function to_string(term) {
  return term.toString();
}
function graphemes(string5) {
  const iterator = graphemes_iterator(string5);
  if (iterator) {
    return List.fromArray(Array.from(iterator).map((item) => item.segment));
  } else {
    return List.fromArray(string5.match(/./gsu));
  }
}
var segmenter = void 0;
function graphemes_iterator(string5) {
  if (globalThis.Intl && Intl.Segmenter) {
    segmenter ||= new Intl.Segmenter();
    return segmenter.segment(string5)[Symbol.iterator]();
  }
}
function lowercase(string5) {
  return string5.toLowerCase();
}
function split(xs, pattern) {
  return List.fromArray(xs.split(pattern));
}
function starts_with(haystack, needle) {
  return haystack.startsWith(needle);
}
var unicode_whitespaces = [
  " ",
  // Space
  "	",
  // Horizontal tab
  "\n",
  // Line feed
  "\v",
  // Vertical tab
  "\f",
  // Form feed
  "\r",
  // Carriage return
  "\x85",
  // Next line
  "\u2028",
  // Line separator
  "\u2029"
  // Paragraph separator
].join("");
var trim_start_regex = /* @__PURE__ */ new RegExp(
  `^[${unicode_whitespaces}]*`
);
var trim_end_regex = /* @__PURE__ */ new RegExp(`[${unicode_whitespaces}]*$`);
function round2(float2) {
  return Math.round(float2);
}
function new_map() {
  return Dict.new();
}
function map_get(map8, key2) {
  const value2 = map8.get(key2, NOT_FOUND);
  if (value2 === NOT_FOUND) {
    return new Error(Nil);
  }
  return new Ok(value2);
}
function map_insert(key2, value2, map8) {
  return map8.set(key2, value2);
}
function classify_dynamic(data) {
  if (typeof data === "string") {
    return "String";
  } else if (typeof data === "boolean") {
    return "Bool";
  } else if (data instanceof Result) {
    return "Result";
  } else if (data instanceof List) {
    return "List";
  } else if (data instanceof BitArray) {
    return "BitArray";
  } else if (data instanceof Dict) {
    return "Dict";
  } else if (Number.isInteger(data)) {
    return "Int";
  } else if (Array.isArray(data)) {
    return `Array`;
  } else if (typeof data === "number") {
    return "Float";
  } else if (data === null) {
    return "Nil";
  } else if (data === void 0) {
    return "Nil";
  } else {
    const type = typeof data;
    return type.charAt(0).toUpperCase() + type.slice(1);
  }
}
function bitwise_and(x, y) {
  return Number(BigInt(x) & BigInt(y));
}
function bitwise_or(x, y) {
  return Number(BigInt(x) | BigInt(y));
}
function bitwise_shift_left(x, y) {
  return Number(BigInt(x) << BigInt(y));
}
function float_to_string(float2) {
  const string5 = float2.toString().replace("+", "");
  if (string5.indexOf(".") >= 0) {
    return string5;
  } else {
    const index4 = string5.indexOf("e");
    if (index4 >= 0) {
      return string5.slice(0, index4) + ".0" + string5.slice(index4);
    } else {
      return string5 + ".0";
    }
  }
}
function index2(data, key2) {
  if (data instanceof Dict || data instanceof WeakMap || data instanceof Map) {
    const token2 = {};
    const entry = data.get(key2, token2);
    if (entry === token2) return new Ok(new None());
    return new Ok(new Some(entry));
  }
  const key_is_int = Number.isInteger(key2);
  if (key_is_int && key2 >= 0 && key2 < 8 && data instanceof List) {
    let i = 0;
    for (const value2 of data) {
      if (i === key2) return new Ok(new Some(value2));
      i++;
    }
    return new Error("Indexable");
  }
  if (key_is_int && Array.isArray(data) || data && typeof data === "object" || data && Object.getPrototypeOf(data) === Object.prototype) {
    if (key2 in data) return new Ok(new Some(data[key2]));
    return new Ok(new None());
  }
  return new Error(key_is_int ? "Indexable" : "Dict");
}
function int(data) {
  if (Number.isInteger(data)) return new Ok(data);
  return new Error(0);
}
function string(data) {
  if (typeof data === "string") return new Ok(data);
  return new Error("");
}

// build/dev/javascript/gleam_stdlib/gleam/float.mjs
function compare(a, b) {
  let $ = a === b;
  if ($) {
    return new Eq();
  } else {
    let $1 = a < b;
    if ($1) {
      return new Lt();
    } else {
      return new Gt();
    }
  }
}
function negate(x) {
  return -1 * x;
}
function round(x) {
  let $ = x >= 0;
  if ($) {
    return round2(x);
  } else {
    return 0 - round2(negate(x));
  }
}

// build/dev/javascript/gleam_stdlib/gleam/int.mjs
function compare2(a, b) {
  let $ = a === b;
  if ($) {
    return new Eq();
  } else {
    let $1 = a < b;
    if ($1) {
      return new Lt();
    } else {
      return new Gt();
    }
  }
}

// build/dev/javascript/gleam_stdlib/gleam/result.mjs
function is_ok(result) {
  if (result instanceof Ok) {
    return true;
  } else {
    return false;
  }
}
function unwrap(result, default$) {
  if (result instanceof Ok) {
    let v = result[0];
    return v;
  } else {
    return default$;
  }
}

// build/dev/javascript/gleam_stdlib/gleam/bool.mjs
function guard(requirement, consequence, alternative) {
  if (requirement) {
    return consequence;
  } else {
    return alternative();
  }
}

// build/dev/javascript/gleam_stdlib/gleam/function.mjs
function identity2(x) {
  return x;
}

// build/dev/javascript/gleam_json/gleam_json_ffi.mjs
function object(entries) {
  return Object.fromEntries(entries);
}
function identity3(x) {
  return x;
}
function array(list4) {
  return list4.toArray();
}

// build/dev/javascript/gleam_json/gleam/json.mjs
function string3(input) {
  return identity3(input);
}
function bool(input) {
  return identity3(input);
}
function object2(entries) {
  return object(entries);
}
function preprocessed_array(from) {
  return array(from);
}
function array2(entries, inner_type) {
  let _pipe = entries;
  let _pipe$1 = map2(_pipe, inner_type);
  return preprocessed_array(_pipe$1);
}

// build/dev/javascript/gleam_stdlib/gleam/set.mjs
var Set2 = class extends CustomType {
  constructor(dict3) {
    super();
    this.dict = dict3;
  }
};
function new$() {
  return new Set2(new_map());
}
function contains(set, member) {
  let _pipe = set.dict;
  let _pipe$1 = map_get(_pipe, member);
  return is_ok(_pipe$1);
}
var token = void 0;
function insert2(set, member) {
  return new Set2(insert(set.dict, member, token));
}

// build/dev/javascript/lustre/lustre/internals/constants.ffi.mjs
var document = () => globalThis?.document;
var NAMESPACE_HTML = "http://www.w3.org/1999/xhtml";
var ELEMENT_NODE = 1;
var TEXT_NODE = 3;
var SUPPORTS_MOVE_BEFORE = !!globalThis.HTMLElement?.prototype?.moveBefore;

// build/dev/javascript/lustre/lustre/internals/constants.mjs
var empty_list = /* @__PURE__ */ toList([]);
var option_none = /* @__PURE__ */ new None();

// build/dev/javascript/lustre/lustre/vdom/vattr.ffi.mjs
var GT = /* @__PURE__ */ new Gt();
var LT = /* @__PURE__ */ new Lt();
var EQ = /* @__PURE__ */ new Eq();
function compare3(a, b) {
  if (a.name === b.name) {
    return EQ;
  } else if (a.name < b.name) {
    return LT;
  } else {
    return GT;
  }
}

// build/dev/javascript/lustre/lustre/vdom/vattr.mjs
var Attribute = class extends CustomType {
  constructor(kind, name, value2) {
    super();
    this.kind = kind;
    this.name = name;
    this.value = value2;
  }
};
var Property = class extends CustomType {
  constructor(kind, name, value2) {
    super();
    this.kind = kind;
    this.name = name;
    this.value = value2;
  }
};
var Event2 = class extends CustomType {
  constructor(kind, name, handler, include, prevent_default, stop_propagation, immediate, debounce, throttle) {
    super();
    this.kind = kind;
    this.name = name;
    this.handler = handler;
    this.include = include;
    this.prevent_default = prevent_default;
    this.stop_propagation = stop_propagation;
    this.immediate = immediate;
    this.debounce = debounce;
    this.throttle = throttle;
  }
};
var Handler = class extends CustomType {
  constructor(prevent_default, stop_propagation, message) {
    super();
    this.prevent_default = prevent_default;
    this.stop_propagation = stop_propagation;
    this.message = message;
  }
};
var Never = class extends CustomType {
  constructor(kind) {
    super();
    this.kind = kind;
  }
};
function merge(loop$attributes, loop$merged) {
  while (true) {
    let attributes = loop$attributes;
    let merged = loop$merged;
    if (attributes instanceof Empty) {
      return merged;
    } else {
      let $ = attributes.head;
      if ($ instanceof Attribute) {
        let $1 = $.name;
        if ($1 === "") {
          let rest = attributes.tail;
          loop$attributes = rest;
          loop$merged = merged;
        } else if ($1 === "class") {
          let $2 = $.value;
          if ($2 === "") {
            let rest = attributes.tail;
            loop$attributes = rest;
            loop$merged = merged;
          } else {
            let $3 = attributes.tail;
            if ($3 instanceof Empty) {
              let attribute$1 = $;
              let rest = $3;
              loop$attributes = rest;
              loop$merged = prepend(attribute$1, merged);
            } else {
              let $4 = $3.head;
              if ($4 instanceof Attribute) {
                let $5 = $4.name;
                if ($5 === "class") {
                  let kind = $.kind;
                  let class1 = $2;
                  let rest = $3.tail;
                  let class2 = $4.value;
                  let value2 = class1 + " " + class2;
                  let attribute$1 = new Attribute(kind, "class", value2);
                  loop$attributes = prepend(attribute$1, rest);
                  loop$merged = merged;
                } else {
                  let attribute$1 = $;
                  let rest = $3;
                  loop$attributes = rest;
                  loop$merged = prepend(attribute$1, merged);
                }
              } else {
                let attribute$1 = $;
                let rest = $3;
                loop$attributes = rest;
                loop$merged = prepend(attribute$1, merged);
              }
            }
          }
        } else if ($1 === "style") {
          let $2 = $.value;
          if ($2 === "") {
            let rest = attributes.tail;
            loop$attributes = rest;
            loop$merged = merged;
          } else {
            let $3 = attributes.tail;
            if ($3 instanceof Empty) {
              let attribute$1 = $;
              let rest = $3;
              loop$attributes = rest;
              loop$merged = prepend(attribute$1, merged);
            } else {
              let $4 = $3.head;
              if ($4 instanceof Attribute) {
                let $5 = $4.name;
                if ($5 === "style") {
                  let kind = $.kind;
                  let style1 = $2;
                  let rest = $3.tail;
                  let style2 = $4.value;
                  let value2 = style1 + ";" + style2;
                  let attribute$1 = new Attribute(kind, "style", value2);
                  loop$attributes = prepend(attribute$1, rest);
                  loop$merged = merged;
                } else {
                  let attribute$1 = $;
                  let rest = $3;
                  loop$attributes = rest;
                  loop$merged = prepend(attribute$1, merged);
                }
              } else {
                let attribute$1 = $;
                let rest = $3;
                loop$attributes = rest;
                loop$merged = prepend(attribute$1, merged);
              }
            }
          }
        } else {
          let attribute$1 = $;
          let rest = attributes.tail;
          loop$attributes = rest;
          loop$merged = prepend(attribute$1, merged);
        }
      } else {
        let attribute$1 = $;
        let rest = attributes.tail;
        loop$attributes = rest;
        loop$merged = prepend(attribute$1, merged);
      }
    }
  }
}
function prepare(attributes) {
  if (attributes instanceof Empty) {
    return attributes;
  } else {
    let $ = attributes.tail;
    if ($ instanceof Empty) {
      return attributes;
    } else {
      let _pipe = attributes;
      let _pipe$1 = sort(_pipe, (a, b) => {
        return compare3(b, a);
      });
      return merge(_pipe$1, empty_list);
    }
  }
}
var attribute_kind = 0;
function attribute(name, value2) {
  return new Attribute(attribute_kind, name, value2);
}
var property_kind = 1;
function property(name, value2) {
  return new Property(property_kind, name, value2);
}
var event_kind = 2;
function event(name, handler, include, prevent_default, stop_propagation, immediate, debounce, throttle) {
  return new Event2(
    event_kind,
    name,
    handler,
    include,
    prevent_default,
    stop_propagation,
    immediate,
    debounce,
    throttle
  );
}
var never_kind = 0;
var never = /* @__PURE__ */ new Never(never_kind);
var always_kind = 2;

// build/dev/javascript/lustre/lustre/attribute.mjs
function attribute2(name, value2) {
  return attribute(name, value2);
}
function property2(name, value2) {
  return property(name, value2);
}
function boolean_attribute(name, value2) {
  if (value2) {
    return attribute2(name, "");
  } else {
    return property2(name, bool(false));
  }
}
function class$(name) {
  return attribute2("class", name);
}
function tabindex(index4) {
  return attribute2("tabindex", to_string(index4));
}
function disabled(is_disabled) {
  return boolean_attribute("disabled", is_disabled);
}
function aria(name, value2) {
  return attribute2("aria-" + name, value2);
}
function role(name) {
  return attribute2("role", name);
}
function aria_label(value2) {
  return aria("label", value2);
}
function aria_live(value2) {
  return aria("live", value2);
}

// build/dev/javascript/lustre/lustre/effect.mjs
var Effect = class extends CustomType {
  constructor(synchronous, before_paint2, after_paint) {
    super();
    this.synchronous = synchronous;
    this.before_paint = before_paint2;
    this.after_paint = after_paint;
  }
};
var empty = /* @__PURE__ */ new Effect(
  /* @__PURE__ */ toList([]),
  /* @__PURE__ */ toList([]),
  /* @__PURE__ */ toList([])
);
function none() {
  return empty;
}

// build/dev/javascript/lustre/lustre/internals/mutable_map.ffi.mjs
function empty2() {
  return null;
}
function get(map8, key2) {
  const value2 = map8?.get(key2);
  if (value2 != null) {
    return new Ok(value2);
  } else {
    return new Error(void 0);
  }
}
function has_key2(map8, key2) {
  return map8 && map8.has(key2);
}
function insert3(map8, key2, value2) {
  map8 ??= /* @__PURE__ */ new Map();
  map8.set(key2, value2);
  return map8;
}
function remove(map8, key2) {
  map8?.delete(key2);
  return map8;
}

// build/dev/javascript/lustre/lustre/vdom/path.mjs
var Root = class extends CustomType {
};
var Key = class extends CustomType {
  constructor(key2, parent) {
    super();
    this.key = key2;
    this.parent = parent;
  }
};
var Index = class extends CustomType {
  constructor(index4, parent) {
    super();
    this.index = index4;
    this.parent = parent;
  }
};
function do_matches(loop$path, loop$candidates) {
  while (true) {
    let path = loop$path;
    let candidates = loop$candidates;
    if (candidates instanceof Empty) {
      return false;
    } else {
      let candidate = candidates.head;
      let rest = candidates.tail;
      let $ = starts_with(path, candidate);
      if ($) {
        return $;
      } else {
        loop$path = path;
        loop$candidates = rest;
      }
    }
  }
}
function add2(parent, index4, key2) {
  if (key2 === "") {
    return new Index(index4, parent);
  } else {
    return new Key(key2, parent);
  }
}
var root2 = /* @__PURE__ */ new Root();
var separator_element = "	";
function do_to_string(loop$path, loop$acc) {
  while (true) {
    let path = loop$path;
    let acc = loop$acc;
    if (path instanceof Root) {
      if (acc instanceof Empty) {
        return "";
      } else {
        let segments = acc.tail;
        return concat2(segments);
      }
    } else if (path instanceof Key) {
      let key2 = path.key;
      let parent = path.parent;
      loop$path = parent;
      loop$acc = prepend(separator_element, prepend(key2, acc));
    } else {
      let index4 = path.index;
      let parent = path.parent;
      loop$path = parent;
      loop$acc = prepend(
        separator_element,
        prepend(to_string(index4), acc)
      );
    }
  }
}
function to_string2(path) {
  return do_to_string(path, toList([]));
}
function matches(path, candidates) {
  if (candidates instanceof Empty) {
    return false;
  } else {
    return do_matches(to_string2(path), candidates);
  }
}
var separator_event = "\n";
function event2(path, event4) {
  return do_to_string(path, toList([separator_event, event4]));
}

// build/dev/javascript/lustre/lustre/vdom/vnode.mjs
var Fragment = class extends CustomType {
  constructor(kind, key2, mapper, children, keyed_children) {
    super();
    this.kind = kind;
    this.key = key2;
    this.mapper = mapper;
    this.children = children;
    this.keyed_children = keyed_children;
  }
};
var Element = class extends CustomType {
  constructor(kind, key2, mapper, namespace, tag, attributes, children, keyed_children, self_closing, void$) {
    super();
    this.kind = kind;
    this.key = key2;
    this.mapper = mapper;
    this.namespace = namespace;
    this.tag = tag;
    this.attributes = attributes;
    this.children = children;
    this.keyed_children = keyed_children;
    this.self_closing = self_closing;
    this.void = void$;
  }
};
var Text = class extends CustomType {
  constructor(kind, key2, mapper, content) {
    super();
    this.kind = kind;
    this.key = key2;
    this.mapper = mapper;
    this.content = content;
  }
};
var UnsafeInnerHtml = class extends CustomType {
  constructor(kind, key2, mapper, namespace, tag, attributes, inner_html) {
    super();
    this.kind = kind;
    this.key = key2;
    this.mapper = mapper;
    this.namespace = namespace;
    this.tag = tag;
    this.attributes = attributes;
    this.inner_html = inner_html;
  }
};
function is_void_element(tag, namespace) {
  if (namespace === "") {
    if (tag === "area") {
      return true;
    } else if (tag === "base") {
      return true;
    } else if (tag === "br") {
      return true;
    } else if (tag === "col") {
      return true;
    } else if (tag === "embed") {
      return true;
    } else if (tag === "hr") {
      return true;
    } else if (tag === "img") {
      return true;
    } else if (tag === "input") {
      return true;
    } else if (tag === "link") {
      return true;
    } else if (tag === "meta") {
      return true;
    } else if (tag === "param") {
      return true;
    } else if (tag === "source") {
      return true;
    } else if (tag === "track") {
      return true;
    } else if (tag === "wbr") {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}
function to_keyed(key2, node) {
  if (node instanceof Fragment) {
    return new Fragment(
      node.kind,
      key2,
      node.mapper,
      node.children,
      node.keyed_children
    );
  } else if (node instanceof Element) {
    return new Element(
      node.kind,
      key2,
      node.mapper,
      node.namespace,
      node.tag,
      node.attributes,
      node.children,
      node.keyed_children,
      node.self_closing,
      node.void
    );
  } else if (node instanceof Text) {
    return new Text(node.kind, key2, node.mapper, node.content);
  } else {
    return new UnsafeInnerHtml(
      node.kind,
      key2,
      node.mapper,
      node.namespace,
      node.tag,
      node.attributes,
      node.inner_html
    );
  }
}
var fragment_kind = 0;
function fragment(key2, mapper, children, keyed_children) {
  return new Fragment(fragment_kind, key2, mapper, children, keyed_children);
}
var element_kind = 1;
function element(key2, mapper, namespace, tag, attributes, children, keyed_children, self_closing, void$) {
  return new Element(
    element_kind,
    key2,
    mapper,
    namespace,
    tag,
    prepare(attributes),
    children,
    keyed_children,
    self_closing,
    void$ || is_void_element(tag, namespace)
  );
}
var text_kind = 2;
function text(key2, mapper, content) {
  return new Text(text_kind, key2, mapper, content);
}
var unsafe_inner_html_kind = 3;

// build/dev/javascript/lustre/lustre/internals/equals.ffi.mjs
var isReferenceEqual = (a, b) => a === b;
var isEqual2 = (a, b) => {
  if (a === b) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }
  const type = typeof a;
  if (type !== typeof b) {
    return false;
  }
  if (type !== "object") {
    return false;
  }
  const ctor = a.constructor;
  if (ctor !== b.constructor) {
    return false;
  }
  if (Array.isArray(a)) {
    return areArraysEqual(a, b);
  }
  return areObjectsEqual(a, b);
};
var areArraysEqual = (a, b) => {
  let index4 = a.length;
  if (index4 !== b.length) {
    return false;
  }
  while (index4--) {
    if (!isEqual2(a[index4], b[index4])) {
      return false;
    }
  }
  return true;
};
var areObjectsEqual = (a, b) => {
  const properties = Object.keys(a);
  let index4 = properties.length;
  if (Object.keys(b).length !== index4) {
    return false;
  }
  while (index4--) {
    const property3 = properties[index4];
    if (!Object.hasOwn(b, property3)) {
      return false;
    }
    if (!isEqual2(a[property3], b[property3])) {
      return false;
    }
  }
  return true;
};

// build/dev/javascript/lustre/lustre/vdom/events.mjs
var Events = class extends CustomType {
  constructor(handlers, dispatched_paths, next_dispatched_paths) {
    super();
    this.handlers = handlers;
    this.dispatched_paths = dispatched_paths;
    this.next_dispatched_paths = next_dispatched_paths;
  }
};
function new$3() {
  return new Events(
    empty2(),
    empty_list,
    empty_list
  );
}
function tick(events) {
  return new Events(
    events.handlers,
    events.next_dispatched_paths,
    empty_list
  );
}
function do_remove_event(handlers, path, name) {
  return remove(handlers, event2(path, name));
}
function remove_event(events, path, name) {
  let handlers = do_remove_event(events.handlers, path, name);
  return new Events(
    handlers,
    events.dispatched_paths,
    events.next_dispatched_paths
  );
}
function remove_attributes(handlers, path, attributes) {
  return fold(
    attributes,
    handlers,
    (events, attribute3) => {
      if (attribute3 instanceof Event2) {
        let name = attribute3.name;
        return do_remove_event(events, path, name);
      } else {
        return events;
      }
    }
  );
}
function handle(events, path, name, event4) {
  let next_dispatched_paths = prepend(path, events.next_dispatched_paths);
  let events$1 = new Events(
    events.handlers,
    events.dispatched_paths,
    next_dispatched_paths
  );
  let $ = get(
    events$1.handlers,
    path + separator_event + name
  );
  if ($ instanceof Ok) {
    let handler = $[0];
    return [events$1, run(event4, handler)];
  } else {
    return [events$1, new Error(toList([]))];
  }
}
function has_dispatched_events(events, path) {
  return matches(path, events.dispatched_paths);
}
function do_add_event(handlers, mapper, path, name, handler) {
  return insert3(
    handlers,
    event2(path, name),
    map3(
      handler,
      (handler2) => {
        return new Handler(
          handler2.prevent_default,
          handler2.stop_propagation,
          identity2(mapper)(handler2.message)
        );
      }
    )
  );
}
function add_event(events, mapper, path, name, handler) {
  let handlers = do_add_event(events.handlers, mapper, path, name, handler);
  return new Events(
    handlers,
    events.dispatched_paths,
    events.next_dispatched_paths
  );
}
function add_attributes(handlers, mapper, path, attributes) {
  return fold(
    attributes,
    handlers,
    (events, attribute3) => {
      if (attribute3 instanceof Event2) {
        let name = attribute3.name;
        let handler = attribute3.handler;
        return do_add_event(events, mapper, path, name, handler);
      } else {
        return events;
      }
    }
  );
}
function compose_mapper(mapper, child_mapper) {
  let $ = isReferenceEqual(mapper, identity2);
  let $1 = isReferenceEqual(child_mapper, identity2);
  if ($1) {
    return mapper;
  } else if ($) {
    return child_mapper;
  } else {
    return (msg) => {
      return mapper(child_mapper(msg));
    };
  }
}
function do_remove_children(loop$handlers, loop$path, loop$child_index, loop$children) {
  while (true) {
    let handlers = loop$handlers;
    let path = loop$path;
    let child_index = loop$child_index;
    let children = loop$children;
    if (children instanceof Empty) {
      return handlers;
    } else {
      let child = children.head;
      let rest = children.tail;
      let _pipe = handlers;
      let _pipe$1 = do_remove_child(_pipe, path, child_index, child);
      loop$handlers = _pipe$1;
      loop$path = path;
      loop$child_index = child_index + 1;
      loop$children = rest;
    }
  }
}
function do_remove_child(handlers, parent, child_index, child) {
  if (child instanceof Fragment) {
    let children = child.children;
    let path = add2(parent, child_index, child.key);
    return do_remove_children(handlers, path, 0, children);
  } else if (child instanceof Element) {
    let attributes = child.attributes;
    let children = child.children;
    let path = add2(parent, child_index, child.key);
    let _pipe = handlers;
    let _pipe$1 = remove_attributes(_pipe, path, attributes);
    return do_remove_children(_pipe$1, path, 0, children);
  } else if (child instanceof Text) {
    return handlers;
  } else {
    let attributes = child.attributes;
    let path = add2(parent, child_index, child.key);
    return remove_attributes(handlers, path, attributes);
  }
}
function remove_child(events, parent, child_index, child) {
  let handlers = do_remove_child(events.handlers, parent, child_index, child);
  return new Events(
    handlers,
    events.dispatched_paths,
    events.next_dispatched_paths
  );
}
function do_add_children(loop$handlers, loop$mapper, loop$path, loop$child_index, loop$children) {
  while (true) {
    let handlers = loop$handlers;
    let mapper = loop$mapper;
    let path = loop$path;
    let child_index = loop$child_index;
    let children = loop$children;
    if (children instanceof Empty) {
      return handlers;
    } else {
      let child = children.head;
      let rest = children.tail;
      let _pipe = handlers;
      let _pipe$1 = do_add_child(_pipe, mapper, path, child_index, child);
      loop$handlers = _pipe$1;
      loop$mapper = mapper;
      loop$path = path;
      loop$child_index = child_index + 1;
      loop$children = rest;
    }
  }
}
function do_add_child(handlers, mapper, parent, child_index, child) {
  if (child instanceof Fragment) {
    let children = child.children;
    let path = add2(parent, child_index, child.key);
    let composed_mapper = compose_mapper(mapper, child.mapper);
    return do_add_children(handlers, composed_mapper, path, 0, children);
  } else if (child instanceof Element) {
    let attributes = child.attributes;
    let children = child.children;
    let path = add2(parent, child_index, child.key);
    let composed_mapper = compose_mapper(mapper, child.mapper);
    let _pipe = handlers;
    let _pipe$1 = add_attributes(_pipe, composed_mapper, path, attributes);
    return do_add_children(_pipe$1, composed_mapper, path, 0, children);
  } else if (child instanceof Text) {
    return handlers;
  } else {
    let attributes = child.attributes;
    let path = add2(parent, child_index, child.key);
    let composed_mapper = compose_mapper(mapper, child.mapper);
    return add_attributes(handlers, composed_mapper, path, attributes);
  }
}
function add_child(events, mapper, parent, index4, child) {
  let handlers = do_add_child(events.handlers, mapper, parent, index4, child);
  return new Events(
    handlers,
    events.dispatched_paths,
    events.next_dispatched_paths
  );
}
function add_children(events, mapper, path, child_index, children) {
  let handlers = do_add_children(
    events.handlers,
    mapper,
    path,
    child_index,
    children
  );
  return new Events(
    handlers,
    events.dispatched_paths,
    events.next_dispatched_paths
  );
}

// build/dev/javascript/lustre/lustre/element.mjs
function element2(tag, attributes, children) {
  return element(
    "",
    identity2,
    "",
    tag,
    attributes,
    children,
    empty2(),
    false,
    false
  );
}
function text2(content) {
  return text("", identity2, content);
}
function none2() {
  return text("", identity2, "");
}

// build/dev/javascript/lustre/lustre/element/html.mjs
function text3(content) {
  return text2(content);
}
function div(attrs, children) {
  return element2("div", attrs, children);
}
function p(attrs, children) {
  return element2("p", attrs, children);
}
function s(attrs, children) {
  return element2("s", attrs, children);
}
function u(attrs, children) {
  return element2("u", attrs, children);
}

// build/dev/javascript/lustre/lustre/vdom/patch.mjs
var Patch = class extends CustomType {
  constructor(index4, removed, changes, children) {
    super();
    this.index = index4;
    this.removed = removed;
    this.changes = changes;
    this.children = children;
  }
};
var ReplaceText = class extends CustomType {
  constructor(kind, content) {
    super();
    this.kind = kind;
    this.content = content;
  }
};
var ReplaceInnerHtml = class extends CustomType {
  constructor(kind, inner_html) {
    super();
    this.kind = kind;
    this.inner_html = inner_html;
  }
};
var Update = class extends CustomType {
  constructor(kind, added, removed) {
    super();
    this.kind = kind;
    this.added = added;
    this.removed = removed;
  }
};
var Move = class extends CustomType {
  constructor(kind, key2, before) {
    super();
    this.kind = kind;
    this.key = key2;
    this.before = before;
  }
};
var Replace = class extends CustomType {
  constructor(kind, index4, with$) {
    super();
    this.kind = kind;
    this.index = index4;
    this.with = with$;
  }
};
var Remove = class extends CustomType {
  constructor(kind, index4) {
    super();
    this.kind = kind;
    this.index = index4;
  }
};
var Insert = class extends CustomType {
  constructor(kind, children, before) {
    super();
    this.kind = kind;
    this.children = children;
    this.before = before;
  }
};
function new$5(index4, removed, changes, children) {
  return new Patch(index4, removed, changes, children);
}
var replace_text_kind = 0;
function replace_text(content) {
  return new ReplaceText(replace_text_kind, content);
}
var replace_inner_html_kind = 1;
function replace_inner_html(inner_html) {
  return new ReplaceInnerHtml(replace_inner_html_kind, inner_html);
}
var update_kind = 2;
function update(added, removed) {
  return new Update(update_kind, added, removed);
}
var move_kind = 3;
function move(key2, before) {
  return new Move(move_kind, key2, before);
}
var remove_kind = 4;
function remove2(index4) {
  return new Remove(remove_kind, index4);
}
var replace_kind = 5;
function replace2(index4, with$) {
  return new Replace(replace_kind, index4, with$);
}
var insert_kind = 6;
function insert4(children, before) {
  return new Insert(insert_kind, children, before);
}

// build/dev/javascript/lustre/lustre/vdom/diff.mjs
var Diff = class extends CustomType {
  constructor(patch, events) {
    super();
    this.patch = patch;
    this.events = events;
  }
};
var AttributeChange = class extends CustomType {
  constructor(added, removed, events) {
    super();
    this.added = added;
    this.removed = removed;
    this.events = events;
  }
};
function is_controlled(events, namespace, tag, path) {
  if (tag === "input" && namespace === "") {
    return has_dispatched_events(events, path);
  } else if (tag === "select" && namespace === "") {
    return has_dispatched_events(events, path);
  } else if (tag === "textarea" && namespace === "") {
    return has_dispatched_events(events, path);
  } else {
    return false;
  }
}
function diff_attributes(loop$controlled, loop$path, loop$mapper, loop$events, loop$old, loop$new, loop$added, loop$removed) {
  while (true) {
    let controlled = loop$controlled;
    let path = loop$path;
    let mapper = loop$mapper;
    let events = loop$events;
    let old = loop$old;
    let new$8 = loop$new;
    let added = loop$added;
    let removed = loop$removed;
    if (new$8 instanceof Empty) {
      if (old instanceof Empty) {
        return new AttributeChange(added, removed, events);
      } else {
        let $ = old.head;
        if ($ instanceof Event2) {
          let prev = $;
          let old$1 = old.tail;
          let name = $.name;
          let removed$1 = prepend(prev, removed);
          let events$1 = remove_event(events, path, name);
          loop$controlled = controlled;
          loop$path = path;
          loop$mapper = mapper;
          loop$events = events$1;
          loop$old = old$1;
          loop$new = new$8;
          loop$added = added;
          loop$removed = removed$1;
        } else {
          let prev = $;
          let old$1 = old.tail;
          let removed$1 = prepend(prev, removed);
          loop$controlled = controlled;
          loop$path = path;
          loop$mapper = mapper;
          loop$events = events;
          loop$old = old$1;
          loop$new = new$8;
          loop$added = added;
          loop$removed = removed$1;
        }
      }
    } else if (old instanceof Empty) {
      let $ = new$8.head;
      if ($ instanceof Event2) {
        let next = $;
        let new$1 = new$8.tail;
        let name = $.name;
        let handler = $.handler;
        let added$1 = prepend(next, added);
        let events$1 = add_event(events, mapper, path, name, handler);
        loop$controlled = controlled;
        loop$path = path;
        loop$mapper = mapper;
        loop$events = events$1;
        loop$old = old;
        loop$new = new$1;
        loop$added = added$1;
        loop$removed = removed;
      } else {
        let next = $;
        let new$1 = new$8.tail;
        let added$1 = prepend(next, added);
        loop$controlled = controlled;
        loop$path = path;
        loop$mapper = mapper;
        loop$events = events;
        loop$old = old;
        loop$new = new$1;
        loop$added = added$1;
        loop$removed = removed;
      }
    } else {
      let next = new$8.head;
      let remaining_new = new$8.tail;
      let prev = old.head;
      let remaining_old = old.tail;
      let $ = compare3(prev, next);
      if ($ instanceof Lt) {
        if (prev instanceof Event2) {
          let name = prev.name;
          let removed$1 = prepend(prev, removed);
          let events$1 = remove_event(events, path, name);
          loop$controlled = controlled;
          loop$path = path;
          loop$mapper = mapper;
          loop$events = events$1;
          loop$old = remaining_old;
          loop$new = new$8;
          loop$added = added;
          loop$removed = removed$1;
        } else {
          let removed$1 = prepend(prev, removed);
          loop$controlled = controlled;
          loop$path = path;
          loop$mapper = mapper;
          loop$events = events;
          loop$old = remaining_old;
          loop$new = new$8;
          loop$added = added;
          loop$removed = removed$1;
        }
      } else if ($ instanceof Eq) {
        if (next instanceof Attribute) {
          if (prev instanceof Attribute) {
            let _block;
            let $1 = next.name;
            if ($1 === "value") {
              _block = controlled || prev.value !== next.value;
            } else if ($1 === "checked") {
              _block = controlled || prev.value !== next.value;
            } else if ($1 === "selected") {
              _block = controlled || prev.value !== next.value;
            } else {
              _block = prev.value !== next.value;
            }
            let has_changes = _block;
            let _block$1;
            if (has_changes) {
              _block$1 = prepend(next, added);
            } else {
              _block$1 = added;
            }
            let added$1 = _block$1;
            loop$controlled = controlled;
            loop$path = path;
            loop$mapper = mapper;
            loop$events = events;
            loop$old = remaining_old;
            loop$new = remaining_new;
            loop$added = added$1;
            loop$removed = removed;
          } else if (prev instanceof Event2) {
            let name = prev.name;
            let added$1 = prepend(next, added);
            let removed$1 = prepend(prev, removed);
            let events$1 = remove_event(events, path, name);
            loop$controlled = controlled;
            loop$path = path;
            loop$mapper = mapper;
            loop$events = events$1;
            loop$old = remaining_old;
            loop$new = remaining_new;
            loop$added = added$1;
            loop$removed = removed$1;
          } else {
            let added$1 = prepend(next, added);
            let removed$1 = prepend(prev, removed);
            loop$controlled = controlled;
            loop$path = path;
            loop$mapper = mapper;
            loop$events = events;
            loop$old = remaining_old;
            loop$new = remaining_new;
            loop$added = added$1;
            loop$removed = removed$1;
          }
        } else if (next instanceof Property) {
          if (prev instanceof Property) {
            let _block;
            let $1 = next.name;
            if ($1 === "scrollLeft") {
              _block = true;
            } else if ($1 === "scrollRight") {
              _block = true;
            } else if ($1 === "value") {
              _block = controlled || !isEqual2(
                prev.value,
                next.value
              );
            } else if ($1 === "checked") {
              _block = controlled || !isEqual2(
                prev.value,
                next.value
              );
            } else if ($1 === "selected") {
              _block = controlled || !isEqual2(
                prev.value,
                next.value
              );
            } else {
              _block = !isEqual2(prev.value, next.value);
            }
            let has_changes = _block;
            let _block$1;
            if (has_changes) {
              _block$1 = prepend(next, added);
            } else {
              _block$1 = added;
            }
            let added$1 = _block$1;
            loop$controlled = controlled;
            loop$path = path;
            loop$mapper = mapper;
            loop$events = events;
            loop$old = remaining_old;
            loop$new = remaining_new;
            loop$added = added$1;
            loop$removed = removed;
          } else if (prev instanceof Event2) {
            let name = prev.name;
            let added$1 = prepend(next, added);
            let removed$1 = prepend(prev, removed);
            let events$1 = remove_event(events, path, name);
            loop$controlled = controlled;
            loop$path = path;
            loop$mapper = mapper;
            loop$events = events$1;
            loop$old = remaining_old;
            loop$new = remaining_new;
            loop$added = added$1;
            loop$removed = removed$1;
          } else {
            let added$1 = prepend(next, added);
            let removed$1 = prepend(prev, removed);
            loop$controlled = controlled;
            loop$path = path;
            loop$mapper = mapper;
            loop$events = events;
            loop$old = remaining_old;
            loop$new = remaining_new;
            loop$added = added$1;
            loop$removed = removed$1;
          }
        } else if (prev instanceof Event2) {
          let name = next.name;
          let handler = next.handler;
          let has_changes = prev.prevent_default.kind !== next.prevent_default.kind || prev.stop_propagation.kind !== next.stop_propagation.kind || prev.immediate !== next.immediate || prev.debounce !== next.debounce || prev.throttle !== next.throttle;
          let _block;
          if (has_changes) {
            _block = prepend(next, added);
          } else {
            _block = added;
          }
          let added$1 = _block;
          let events$1 = add_event(events, mapper, path, name, handler);
          loop$controlled = controlled;
          loop$path = path;
          loop$mapper = mapper;
          loop$events = events$1;
          loop$old = remaining_old;
          loop$new = remaining_new;
          loop$added = added$1;
          loop$removed = removed;
        } else {
          let name = next.name;
          let handler = next.handler;
          let added$1 = prepend(next, added);
          let removed$1 = prepend(prev, removed);
          let events$1 = add_event(events, mapper, path, name, handler);
          loop$controlled = controlled;
          loop$path = path;
          loop$mapper = mapper;
          loop$events = events$1;
          loop$old = remaining_old;
          loop$new = remaining_new;
          loop$added = added$1;
          loop$removed = removed$1;
        }
      } else if (next instanceof Event2) {
        let name = next.name;
        let handler = next.handler;
        let added$1 = prepend(next, added);
        let events$1 = add_event(events, mapper, path, name, handler);
        loop$controlled = controlled;
        loop$path = path;
        loop$mapper = mapper;
        loop$events = events$1;
        loop$old = old;
        loop$new = remaining_new;
        loop$added = added$1;
        loop$removed = removed;
      } else {
        let added$1 = prepend(next, added);
        loop$controlled = controlled;
        loop$path = path;
        loop$mapper = mapper;
        loop$events = events;
        loop$old = old;
        loop$new = remaining_new;
        loop$added = added$1;
        loop$removed = removed;
      }
    }
  }
}
function do_diff(loop$old, loop$old_keyed, loop$new, loop$new_keyed, loop$moved, loop$moved_offset, loop$removed, loop$node_index, loop$patch_index, loop$path, loop$changes, loop$children, loop$mapper, loop$events) {
  while (true) {
    let old = loop$old;
    let old_keyed = loop$old_keyed;
    let new$8 = loop$new;
    let new_keyed = loop$new_keyed;
    let moved = loop$moved;
    let moved_offset = loop$moved_offset;
    let removed = loop$removed;
    let node_index = loop$node_index;
    let patch_index = loop$patch_index;
    let path = loop$path;
    let changes = loop$changes;
    let children = loop$children;
    let mapper = loop$mapper;
    let events = loop$events;
    if (new$8 instanceof Empty) {
      if (old instanceof Empty) {
        return new Diff(
          new Patch(patch_index, removed, changes, children),
          events
        );
      } else {
        let prev = old.head;
        let old$1 = old.tail;
        let _block;
        let $ = prev.key === "" || !has_key2(moved, prev.key);
        if ($) {
          _block = removed + 1;
        } else {
          _block = removed;
        }
        let removed$1 = _block;
        let events$1 = remove_child(events, path, node_index, prev);
        loop$old = old$1;
        loop$old_keyed = old_keyed;
        loop$new = new$8;
        loop$new_keyed = new_keyed;
        loop$moved = moved;
        loop$moved_offset = moved_offset;
        loop$removed = removed$1;
        loop$node_index = node_index;
        loop$patch_index = patch_index;
        loop$path = path;
        loop$changes = changes;
        loop$children = children;
        loop$mapper = mapper;
        loop$events = events$1;
      }
    } else if (old instanceof Empty) {
      let events$1 = add_children(
        events,
        mapper,
        path,
        node_index,
        new$8
      );
      let insert5 = insert4(new$8, node_index - moved_offset);
      let changes$1 = prepend(insert5, changes);
      return new Diff(
        new Patch(patch_index, removed, changes$1, children),
        events$1
      );
    } else {
      let next = new$8.head;
      let prev = old.head;
      if (prev.key !== next.key) {
        let new_remaining = new$8.tail;
        let old_remaining = old.tail;
        let next_did_exist = get(old_keyed, next.key);
        let prev_does_exist = has_key2(new_keyed, prev.key);
        if (next_did_exist instanceof Ok) {
          if (prev_does_exist) {
            let match = next_did_exist[0];
            let $ = has_key2(moved, prev.key);
            if ($) {
              loop$old = old_remaining;
              loop$old_keyed = old_keyed;
              loop$new = new$8;
              loop$new_keyed = new_keyed;
              loop$moved = moved;
              loop$moved_offset = moved_offset - 1;
              loop$removed = removed;
              loop$node_index = node_index;
              loop$patch_index = patch_index;
              loop$path = path;
              loop$changes = changes;
              loop$children = children;
              loop$mapper = mapper;
              loop$events = events;
            } else {
              let before = node_index - moved_offset;
              let changes$1 = prepend(
                move(next.key, before),
                changes
              );
              let moved$1 = insert3(moved, next.key, void 0);
              let moved_offset$1 = moved_offset + 1;
              loop$old = prepend(match, old);
              loop$old_keyed = old_keyed;
              loop$new = new$8;
              loop$new_keyed = new_keyed;
              loop$moved = moved$1;
              loop$moved_offset = moved_offset$1;
              loop$removed = removed;
              loop$node_index = node_index;
              loop$patch_index = patch_index;
              loop$path = path;
              loop$changes = changes$1;
              loop$children = children;
              loop$mapper = mapper;
              loop$events = events;
            }
          } else {
            let index4 = node_index - moved_offset;
            let changes$1 = prepend(remove2(index4), changes);
            let events$1 = remove_child(events, path, node_index, prev);
            let moved_offset$1 = moved_offset - 1;
            loop$old = old_remaining;
            loop$old_keyed = old_keyed;
            loop$new = new$8;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset$1;
            loop$removed = removed;
            loop$node_index = node_index;
            loop$patch_index = patch_index;
            loop$path = path;
            loop$changes = changes$1;
            loop$children = children;
            loop$mapper = mapper;
            loop$events = events$1;
          }
        } else if (prev_does_exist) {
          let before = node_index - moved_offset;
          let events$1 = add_child(
            events,
            mapper,
            path,
            node_index,
            next
          );
          let insert5 = insert4(toList([next]), before);
          let changes$1 = prepend(insert5, changes);
          loop$old = old;
          loop$old_keyed = old_keyed;
          loop$new = new_remaining;
          loop$new_keyed = new_keyed;
          loop$moved = moved;
          loop$moved_offset = moved_offset + 1;
          loop$removed = removed;
          loop$node_index = node_index + 1;
          loop$patch_index = patch_index;
          loop$path = path;
          loop$changes = changes$1;
          loop$children = children;
          loop$mapper = mapper;
          loop$events = events$1;
        } else {
          let change = replace2(node_index - moved_offset, next);
          let _block;
          let _pipe = events;
          let _pipe$1 = remove_child(_pipe, path, node_index, prev);
          _block = add_child(_pipe$1, mapper, path, node_index, next);
          let events$1 = _block;
          loop$old = old_remaining;
          loop$old_keyed = old_keyed;
          loop$new = new_remaining;
          loop$new_keyed = new_keyed;
          loop$moved = moved;
          loop$moved_offset = moved_offset;
          loop$removed = removed;
          loop$node_index = node_index + 1;
          loop$patch_index = patch_index;
          loop$path = path;
          loop$changes = prepend(change, changes);
          loop$children = children;
          loop$mapper = mapper;
          loop$events = events$1;
        }
      } else {
        let $ = old.head;
        if ($ instanceof Fragment) {
          let $1 = new$8.head;
          if ($1 instanceof Fragment) {
            let next$1 = $1;
            let new$1 = new$8.tail;
            let prev$1 = $;
            let old$1 = old.tail;
            let composed_mapper = compose_mapper(mapper, next$1.mapper);
            let child_path = add2(path, node_index, next$1.key);
            let child = do_diff(
              prev$1.children,
              prev$1.keyed_children,
              next$1.children,
              next$1.keyed_children,
              empty2(),
              0,
              0,
              0,
              node_index,
              child_path,
              empty_list,
              empty_list,
              composed_mapper,
              events
            );
            let _block;
            let $2 = child.patch;
            let $3 = $2.children;
            if ($3 instanceof Empty) {
              let $4 = $2.changes;
              if ($4 instanceof Empty) {
                let $5 = $2.removed;
                if ($5 === 0) {
                  _block = children;
                } else {
                  _block = prepend(child.patch, children);
                }
              } else {
                _block = prepend(child.patch, children);
              }
            } else {
              _block = prepend(child.patch, children);
            }
            let children$1 = _block;
            loop$old = old$1;
            loop$old_keyed = old_keyed;
            loop$new = new$1;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset;
            loop$removed = removed;
            loop$node_index = node_index + 1;
            loop$patch_index = patch_index;
            loop$path = path;
            loop$changes = changes;
            loop$children = children$1;
            loop$mapper = mapper;
            loop$events = child.events;
          } else {
            let next$1 = $1;
            let new_remaining = new$8.tail;
            let prev$1 = $;
            let old_remaining = old.tail;
            let change = replace2(node_index - moved_offset, next$1);
            let _block;
            let _pipe = events;
            let _pipe$1 = remove_child(_pipe, path, node_index, prev$1);
            _block = add_child(
              _pipe$1,
              mapper,
              path,
              node_index,
              next$1
            );
            let events$1 = _block;
            loop$old = old_remaining;
            loop$old_keyed = old_keyed;
            loop$new = new_remaining;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset;
            loop$removed = removed;
            loop$node_index = node_index + 1;
            loop$patch_index = patch_index;
            loop$path = path;
            loop$changes = prepend(change, changes);
            loop$children = children;
            loop$mapper = mapper;
            loop$events = events$1;
          }
        } else if ($ instanceof Element) {
          let $1 = new$8.head;
          if ($1 instanceof Element) {
            let next$1 = $1;
            let prev$1 = $;
            if (prev$1.namespace === next$1.namespace && prev$1.tag === next$1.tag) {
              let new$1 = new$8.tail;
              let old$1 = old.tail;
              let composed_mapper = compose_mapper(
                mapper,
                next$1.mapper
              );
              let child_path = add2(path, node_index, next$1.key);
              let controlled = is_controlled(
                events,
                next$1.namespace,
                next$1.tag,
                child_path
              );
              let $2 = diff_attributes(
                controlled,
                child_path,
                composed_mapper,
                events,
                prev$1.attributes,
                next$1.attributes,
                empty_list,
                empty_list
              );
              let added_attrs;
              let removed_attrs;
              let events$1;
              added_attrs = $2.added;
              removed_attrs = $2.removed;
              events$1 = $2.events;
              let _block;
              if (removed_attrs instanceof Empty && added_attrs instanceof Empty) {
                _block = empty_list;
              } else {
                _block = toList([update(added_attrs, removed_attrs)]);
              }
              let initial_child_changes = _block;
              let child = do_diff(
                prev$1.children,
                prev$1.keyed_children,
                next$1.children,
                next$1.keyed_children,
                empty2(),
                0,
                0,
                0,
                node_index,
                child_path,
                initial_child_changes,
                empty_list,
                composed_mapper,
                events$1
              );
              let _block$1;
              let $3 = child.patch;
              let $4 = $3.children;
              if ($4 instanceof Empty) {
                let $5 = $3.changes;
                if ($5 instanceof Empty) {
                  let $6 = $3.removed;
                  if ($6 === 0) {
                    _block$1 = children;
                  } else {
                    _block$1 = prepend(child.patch, children);
                  }
                } else {
                  _block$1 = prepend(child.patch, children);
                }
              } else {
                _block$1 = prepend(child.patch, children);
              }
              let children$1 = _block$1;
              loop$old = old$1;
              loop$old_keyed = old_keyed;
              loop$new = new$1;
              loop$new_keyed = new_keyed;
              loop$moved = moved;
              loop$moved_offset = moved_offset;
              loop$removed = removed;
              loop$node_index = node_index + 1;
              loop$patch_index = patch_index;
              loop$path = path;
              loop$changes = changes;
              loop$children = children$1;
              loop$mapper = mapper;
              loop$events = child.events;
            } else {
              let next$2 = $1;
              let new_remaining = new$8.tail;
              let prev$2 = $;
              let old_remaining = old.tail;
              let change = replace2(node_index - moved_offset, next$2);
              let _block;
              let _pipe = events;
              let _pipe$1 = remove_child(
                _pipe,
                path,
                node_index,
                prev$2
              );
              _block = add_child(
                _pipe$1,
                mapper,
                path,
                node_index,
                next$2
              );
              let events$1 = _block;
              loop$old = old_remaining;
              loop$old_keyed = old_keyed;
              loop$new = new_remaining;
              loop$new_keyed = new_keyed;
              loop$moved = moved;
              loop$moved_offset = moved_offset;
              loop$removed = removed;
              loop$node_index = node_index + 1;
              loop$patch_index = patch_index;
              loop$path = path;
              loop$changes = prepend(change, changes);
              loop$children = children;
              loop$mapper = mapper;
              loop$events = events$1;
            }
          } else {
            let next$1 = $1;
            let new_remaining = new$8.tail;
            let prev$1 = $;
            let old_remaining = old.tail;
            let change = replace2(node_index - moved_offset, next$1);
            let _block;
            let _pipe = events;
            let _pipe$1 = remove_child(_pipe, path, node_index, prev$1);
            _block = add_child(
              _pipe$1,
              mapper,
              path,
              node_index,
              next$1
            );
            let events$1 = _block;
            loop$old = old_remaining;
            loop$old_keyed = old_keyed;
            loop$new = new_remaining;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset;
            loop$removed = removed;
            loop$node_index = node_index + 1;
            loop$patch_index = patch_index;
            loop$path = path;
            loop$changes = prepend(change, changes);
            loop$children = children;
            loop$mapper = mapper;
            loop$events = events$1;
          }
        } else if ($ instanceof Text) {
          let $1 = new$8.head;
          if ($1 instanceof Text) {
            let next$1 = $1;
            let prev$1 = $;
            if (prev$1.content === next$1.content) {
              let new$1 = new$8.tail;
              let old$1 = old.tail;
              loop$old = old$1;
              loop$old_keyed = old_keyed;
              loop$new = new$1;
              loop$new_keyed = new_keyed;
              loop$moved = moved;
              loop$moved_offset = moved_offset;
              loop$removed = removed;
              loop$node_index = node_index + 1;
              loop$patch_index = patch_index;
              loop$path = path;
              loop$changes = changes;
              loop$children = children;
              loop$mapper = mapper;
              loop$events = events;
            } else {
              let next$2 = $1;
              let new$1 = new$8.tail;
              let old$1 = old.tail;
              let child = new$5(
                node_index,
                0,
                toList([replace_text(next$2.content)]),
                empty_list
              );
              loop$old = old$1;
              loop$old_keyed = old_keyed;
              loop$new = new$1;
              loop$new_keyed = new_keyed;
              loop$moved = moved;
              loop$moved_offset = moved_offset;
              loop$removed = removed;
              loop$node_index = node_index + 1;
              loop$patch_index = patch_index;
              loop$path = path;
              loop$changes = changes;
              loop$children = prepend(child, children);
              loop$mapper = mapper;
              loop$events = events;
            }
          } else {
            let next$1 = $1;
            let new_remaining = new$8.tail;
            let prev$1 = $;
            let old_remaining = old.tail;
            let change = replace2(node_index - moved_offset, next$1);
            let _block;
            let _pipe = events;
            let _pipe$1 = remove_child(_pipe, path, node_index, prev$1);
            _block = add_child(
              _pipe$1,
              mapper,
              path,
              node_index,
              next$1
            );
            let events$1 = _block;
            loop$old = old_remaining;
            loop$old_keyed = old_keyed;
            loop$new = new_remaining;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset;
            loop$removed = removed;
            loop$node_index = node_index + 1;
            loop$patch_index = patch_index;
            loop$path = path;
            loop$changes = prepend(change, changes);
            loop$children = children;
            loop$mapper = mapper;
            loop$events = events$1;
          }
        } else {
          let $1 = new$8.head;
          if ($1 instanceof UnsafeInnerHtml) {
            let next$1 = $1;
            let new$1 = new$8.tail;
            let prev$1 = $;
            let old$1 = old.tail;
            let composed_mapper = compose_mapper(mapper, next$1.mapper);
            let child_path = add2(path, node_index, next$1.key);
            let $2 = diff_attributes(
              false,
              child_path,
              composed_mapper,
              events,
              prev$1.attributes,
              next$1.attributes,
              empty_list,
              empty_list
            );
            let added_attrs;
            let removed_attrs;
            let events$1;
            added_attrs = $2.added;
            removed_attrs = $2.removed;
            events$1 = $2.events;
            let _block;
            if (removed_attrs instanceof Empty && added_attrs instanceof Empty) {
              _block = empty_list;
            } else {
              _block = toList([update(added_attrs, removed_attrs)]);
            }
            let child_changes = _block;
            let _block$1;
            let $3 = prev$1.inner_html === next$1.inner_html;
            if ($3) {
              _block$1 = child_changes;
            } else {
              _block$1 = prepend(
                replace_inner_html(next$1.inner_html),
                child_changes
              );
            }
            let child_changes$1 = _block$1;
            let _block$2;
            if (child_changes$1 instanceof Empty) {
              _block$2 = children;
            } else {
              _block$2 = prepend(
                new$5(node_index, 0, child_changes$1, toList([])),
                children
              );
            }
            let children$1 = _block$2;
            loop$old = old$1;
            loop$old_keyed = old_keyed;
            loop$new = new$1;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset;
            loop$removed = removed;
            loop$node_index = node_index + 1;
            loop$patch_index = patch_index;
            loop$path = path;
            loop$changes = changes;
            loop$children = children$1;
            loop$mapper = mapper;
            loop$events = events$1;
          } else {
            let next$1 = $1;
            let new_remaining = new$8.tail;
            let prev$1 = $;
            let old_remaining = old.tail;
            let change = replace2(node_index - moved_offset, next$1);
            let _block;
            let _pipe = events;
            let _pipe$1 = remove_child(_pipe, path, node_index, prev$1);
            _block = add_child(
              _pipe$1,
              mapper,
              path,
              node_index,
              next$1
            );
            let events$1 = _block;
            loop$old = old_remaining;
            loop$old_keyed = old_keyed;
            loop$new = new_remaining;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset;
            loop$removed = removed;
            loop$node_index = node_index + 1;
            loop$patch_index = patch_index;
            loop$path = path;
            loop$changes = prepend(change, changes);
            loop$children = children;
            loop$mapper = mapper;
            loop$events = events$1;
          }
        }
      }
    }
  }
}
function diff(events, old, new$8) {
  return do_diff(
    toList([old]),
    empty2(),
    toList([new$8]),
    empty2(),
    empty2(),
    0,
    0,
    0,
    0,
    root2,
    empty_list,
    empty_list,
    identity2,
    tick(events)
  );
}

// build/dev/javascript/lustre/lustre/vdom/reconciler.ffi.mjs
var setTimeout = globalThis.setTimeout;
var clearTimeout = globalThis.clearTimeout;
var createElementNS = (ns, name) => document().createElementNS(ns, name);
var createTextNode = (data) => document().createTextNode(data);
var createDocumentFragment = () => document().createDocumentFragment();
var insertBefore = (parent, node, reference) => parent.insertBefore(node, reference);
var moveBefore = SUPPORTS_MOVE_BEFORE ? (parent, node, reference) => parent.moveBefore(node, reference) : insertBefore;
var removeChild = (parent, child) => parent.removeChild(child);
var getAttribute = (node, name) => node.getAttribute(name);
var setAttribute = (node, name, value2) => node.setAttribute(name, value2);
var removeAttribute = (node, name) => node.removeAttribute(name);
var addEventListener = (node, name, handler, options) => node.addEventListener(name, handler, options);
var removeEventListener = (node, name, handler) => node.removeEventListener(name, handler);
var setInnerHtml = (node, innerHtml) => node.innerHTML = innerHtml;
var setData = (node, data) => node.data = data;
var meta = Symbol("lustre");
var MetadataNode = class {
  constructor(kind, parent, node, key2) {
    this.kind = kind;
    this.key = key2;
    this.parent = parent;
    this.children = [];
    this.node = node;
    this.handlers = /* @__PURE__ */ new Map();
    this.throttles = /* @__PURE__ */ new Map();
    this.debouncers = /* @__PURE__ */ new Map();
  }
  get parentNode() {
    return this.kind === fragment_kind ? this.node.parentNode : this.node;
  }
};
var insertMetadataChild = (kind, parent, node, index4, key2) => {
  const child = new MetadataNode(kind, parent, node, key2);
  node[meta] = child;
  parent?.children.splice(index4, 0, child);
  return child;
};
var getPath = (node) => {
  let path = "";
  for (let current = node[meta]; current.parent; current = current.parent) {
    if (current.key) {
      path = `${separator_element}${current.key}${path}`;
    } else {
      const index4 = current.parent.children.indexOf(current);
      path = `${separator_element}${index4}${path}`;
    }
  }
  return path.slice(1);
};
var Reconciler = class {
  #root = null;
  #dispatch = () => {
  };
  #useServerEvents = false;
  #exposeKeys = false;
  constructor(root3, dispatch, { useServerEvents = false, exposeKeys = false } = {}) {
    this.#root = root3;
    this.#dispatch = dispatch;
    this.#useServerEvents = useServerEvents;
    this.#exposeKeys = exposeKeys;
  }
  mount(vdom) {
    insertMetadataChild(element_kind, null, this.#root, 0, null);
    this.#insertChild(this.#root, null, this.#root[meta], 0, vdom);
  }
  push(patch) {
    this.#stack.push({ node: this.#root[meta], patch });
    this.#reconcile();
  }
  // PATCHING ------------------------------------------------------------------
  #stack = [];
  #reconcile() {
    const stack = this.#stack;
    while (stack.length) {
      const { node, patch } = stack.pop();
      const { children: childNodes } = node;
      const { changes, removed, children: childPatches } = patch;
      iterate(changes, (change) => this.#patch(node, change));
      if (removed) {
        this.#removeChildren(node, childNodes.length - removed, removed);
      }
      iterate(childPatches, (childPatch) => {
        const child = childNodes[childPatch.index | 0];
        this.#stack.push({ node: child, patch: childPatch });
      });
    }
  }
  #patch(node, change) {
    switch (change.kind) {
      case replace_text_kind:
        this.#replaceText(node, change);
        break;
      case replace_inner_html_kind:
        this.#replaceInnerHtml(node, change);
        break;
      case update_kind:
        this.#update(node, change);
        break;
      case move_kind:
        this.#move(node, change);
        break;
      case remove_kind:
        this.#remove(node, change);
        break;
      case replace_kind:
        this.#replace(node, change);
        break;
      case insert_kind:
        this.#insert(node, change);
        break;
    }
  }
  // CHANGES -------------------------------------------------------------------
  #insert(parent, { children, before }) {
    const fragment3 = createDocumentFragment();
    const beforeEl = this.#getReference(parent, before);
    this.#insertChildren(fragment3, null, parent, before | 0, children);
    insertBefore(parent.parentNode, fragment3, beforeEl);
  }
  #replace(parent, { index: index4, with: child }) {
    this.#removeChildren(parent, index4 | 0, 1);
    const beforeEl = this.#getReference(parent, index4);
    this.#insertChild(parent.parentNode, beforeEl, parent, index4 | 0, child);
  }
  #getReference(node, index4) {
    index4 = index4 | 0;
    const { children } = node;
    const childCount = children.length;
    if (index4 < childCount) {
      return children[index4].node;
    }
    let lastChild = children[childCount - 1];
    if (!lastChild && node.kind !== fragment_kind) return null;
    if (!lastChild) lastChild = node;
    while (lastChild.kind === fragment_kind && lastChild.children.length) {
      lastChild = lastChild.children[lastChild.children.length - 1];
    }
    return lastChild.node.nextSibling;
  }
  #move(parent, { key: key2, before }) {
    before = before | 0;
    const { children, parentNode } = parent;
    const beforeEl = children[before].node;
    let prev = children[before];
    for (let i = before + 1; i < children.length; ++i) {
      const next = children[i];
      children[i] = prev;
      prev = next;
      if (next.key === key2) {
        children[before] = next;
        break;
      }
    }
    const { kind, node, children: prevChildren } = prev;
    moveBefore(parentNode, node, beforeEl);
    if (kind === fragment_kind) {
      this.#moveChildren(parentNode, prevChildren, beforeEl);
    }
  }
  #moveChildren(domParent, children, beforeEl) {
    for (let i = 0; i < children.length; ++i) {
      const { kind, node, children: nestedChildren } = children[i];
      moveBefore(domParent, node, beforeEl);
      if (kind === fragment_kind) {
        this.#moveChildren(domParent, nestedChildren, beforeEl);
      }
    }
  }
  #remove(parent, { index: index4 }) {
    this.#removeChildren(parent, index4, 1);
  }
  #removeChildren(parent, index4, count) {
    const { children, parentNode } = parent;
    const deleted = children.splice(index4, count);
    for (let i = 0; i < deleted.length; ++i) {
      const { kind, node, children: nestedChildren } = deleted[i];
      removeChild(parentNode, node);
      this.#removeDebouncers(deleted[i]);
      if (kind === fragment_kind) {
        deleted.push(...nestedChildren);
      }
    }
  }
  #removeDebouncers(node) {
    const { debouncers, children } = node;
    for (const { timeout } of debouncers.values()) {
      if (timeout) {
        clearTimeout(timeout);
      }
    }
    debouncers.clear();
    iterate(children, (child) => this.#removeDebouncers(child));
  }
  #update({ node, handlers, throttles, debouncers }, { added, removed }) {
    iterate(removed, ({ name }) => {
      if (handlers.delete(name)) {
        removeEventListener(node, name, handleEvent);
        this.#updateDebounceThrottle(throttles, name, 0);
        this.#updateDebounceThrottle(debouncers, name, 0);
      } else {
        removeAttribute(node, name);
        SYNCED_ATTRIBUTES[name]?.removed?.(node, name);
      }
    });
    iterate(added, (attribute3) => this.#createAttribute(node, attribute3));
  }
  #replaceText({ node }, { content }) {
    setData(node, content ?? "");
  }
  #replaceInnerHtml({ node }, { inner_html }) {
    setInnerHtml(node, inner_html ?? "");
  }
  // INSERT --------------------------------------------------------------------
  #insertChildren(domParent, beforeEl, metaParent, index4, children) {
    iterate(
      children,
      (child) => this.#insertChild(domParent, beforeEl, metaParent, index4++, child)
    );
  }
  #insertChild(domParent, beforeEl, metaParent, index4, vnode) {
    switch (vnode.kind) {
      case element_kind: {
        const node = this.#createElement(metaParent, index4, vnode);
        this.#insertChildren(node, null, node[meta], 0, vnode.children);
        insertBefore(domParent, node, beforeEl);
        break;
      }
      case text_kind: {
        const node = this.#createTextNode(metaParent, index4, vnode);
        insertBefore(domParent, node, beforeEl);
        break;
      }
      case fragment_kind: {
        const head = this.#createTextNode(metaParent, index4, vnode);
        insertBefore(domParent, head, beforeEl);
        this.#insertChildren(
          domParent,
          beforeEl,
          head[meta],
          0,
          vnode.children
        );
        break;
      }
      case unsafe_inner_html_kind: {
        const node = this.#createElement(metaParent, index4, vnode);
        this.#replaceInnerHtml({ node }, vnode);
        insertBefore(domParent, node, beforeEl);
        break;
      }
    }
  }
  #createElement(parent, index4, { kind, key: key2, tag, namespace, attributes }) {
    const node = createElementNS(namespace || NAMESPACE_HTML, tag);
    insertMetadataChild(kind, parent, node, index4, key2);
    if (this.#exposeKeys && key2) {
      setAttribute(node, "data-lustre-key", key2);
    }
    iterate(attributes, (attribute3) => this.#createAttribute(node, attribute3));
    return node;
  }
  #createTextNode(parent, index4, { kind, key: key2, content }) {
    const node = createTextNode(content ?? "");
    insertMetadataChild(kind, parent, node, index4, key2);
    return node;
  }
  #createAttribute(node, attribute3) {
    const { debouncers, handlers, throttles } = node[meta];
    const {
      kind,
      name,
      value: value2,
      prevent_default: prevent,
      debounce: debounceDelay,
      throttle: throttleDelay
    } = attribute3;
    switch (kind) {
      case attribute_kind: {
        const valueOrDefault = value2 ?? "";
        if (name === "virtual:defaultValue") {
          node.defaultValue = valueOrDefault;
          return;
        }
        if (valueOrDefault !== getAttribute(node, name)) {
          setAttribute(node, name, valueOrDefault);
        }
        SYNCED_ATTRIBUTES[name]?.added?.(node, valueOrDefault);
        break;
      }
      case property_kind:
        node[name] = value2;
        break;
      case event_kind: {
        if (handlers.has(name)) {
          removeEventListener(node, name, handleEvent);
        }
        const passive = prevent.kind === never_kind;
        addEventListener(node, name, handleEvent, { passive });
        this.#updateDebounceThrottle(throttles, name, throttleDelay);
        this.#updateDebounceThrottle(debouncers, name, debounceDelay);
        handlers.set(name, (event4) => this.#handleEvent(attribute3, event4));
        break;
      }
    }
  }
  #updateDebounceThrottle(map8, name, delay) {
    const debounceOrThrottle = map8.get(name);
    if (delay > 0) {
      if (debounceOrThrottle) {
        debounceOrThrottle.delay = delay;
      } else {
        map8.set(name, { delay });
      }
    } else if (debounceOrThrottle) {
      const { timeout } = debounceOrThrottle;
      if (timeout) {
        clearTimeout(timeout);
      }
      map8.delete(name);
    }
  }
  #handleEvent(attribute3, event4) {
    const { currentTarget, type } = event4;
    const { debouncers, throttles } = currentTarget[meta];
    const path = getPath(currentTarget);
    const {
      prevent_default: prevent,
      stop_propagation: stop,
      include,
      immediate
    } = attribute3;
    if (prevent.kind === always_kind) event4.preventDefault();
    if (stop.kind === always_kind) event4.stopPropagation();
    if (type === "submit") {
      event4.detail ??= {};
      event4.detail.formData = [
        ...new FormData(event4.target, event4.submitter).entries()
      ];
    }
    const data = this.#useServerEvents ? createServerEvent(event4, include ?? []) : event4;
    const throttle = throttles.get(type);
    if (throttle) {
      const now = Date.now();
      const last2 = throttle.last || 0;
      if (now > last2 + throttle.delay) {
        throttle.last = now;
        throttle.lastEvent = event4;
        this.#dispatch(data, path, type, immediate);
      }
    }
    const debounce = debouncers.get(type);
    if (debounce) {
      clearTimeout(debounce.timeout);
      debounce.timeout = setTimeout(() => {
        if (event4 === throttles.get(type)?.lastEvent) return;
        this.#dispatch(data, path, type, immediate);
      }, debounce.delay);
    }
    if (!throttle && !debounce) {
      this.#dispatch(data, path, type, immediate);
    }
  }
};
var iterate = (list4, callback) => {
  if (Array.isArray(list4)) {
    for (let i = 0; i < list4.length; i++) {
      callback(list4[i]);
    }
  } else if (list4) {
    for (list4; list4.head; list4 = list4.tail) {
      callback(list4.head);
    }
  }
};
var handleEvent = (event4) => {
  const { currentTarget, type } = event4;
  const handler = currentTarget[meta].handlers.get(type);
  handler(event4);
};
var createServerEvent = (event4, include = []) => {
  const data = {};
  if (event4.type === "input" || event4.type === "change") {
    include.push("target.value");
  }
  if (event4.type === "submit") {
    include.push("detail.formData");
  }
  for (const property3 of include) {
    const path = property3.split(".");
    for (let i = 0, input = event4, output = data; i < path.length; i++) {
      if (i === path.length - 1) {
        output[path[i]] = input[path[i]];
        break;
      }
      output = output[path[i]] ??= {};
      input = input[path[i]];
    }
  }
  return data;
};
var syncedBooleanAttribute = /* @__NO_SIDE_EFFECTS__ */ (name) => {
  return {
    added(node) {
      node[name] = true;
    },
    removed(node) {
      node[name] = false;
    }
  };
};
var syncedAttribute = /* @__NO_SIDE_EFFECTS__ */ (name) => {
  return {
    added(node, value2) {
      node[name] = value2;
    }
  };
};
var SYNCED_ATTRIBUTES = {
  checked: /* @__PURE__ */ syncedBooleanAttribute("checked"),
  selected: /* @__PURE__ */ syncedBooleanAttribute("selected"),
  value: /* @__PURE__ */ syncedAttribute("value"),
  autofocus: {
    added(node) {
      queueMicrotask(() => {
        node.focus?.();
      });
    }
  },
  autoplay: {
    added(node) {
      try {
        node.play?.();
      } catch (e) {
        console.error(e);
      }
    }
  }
};

// build/dev/javascript/lustre/lustre/element/keyed.mjs
function do_extract_keyed_children(loop$key_children_pairs, loop$keyed_children, loop$children) {
  while (true) {
    let key_children_pairs = loop$key_children_pairs;
    let keyed_children = loop$keyed_children;
    let children = loop$children;
    if (key_children_pairs instanceof Empty) {
      return [keyed_children, reverse3(children)];
    } else {
      let rest = key_children_pairs.tail;
      let key2 = key_children_pairs.head[0];
      let element$1 = key_children_pairs.head[1];
      let keyed_element = to_keyed(key2, element$1);
      let _block;
      if (key2 === "") {
        _block = keyed_children;
      } else {
        _block = insert3(keyed_children, key2, keyed_element);
      }
      let keyed_children$1 = _block;
      let children$1 = prepend(keyed_element, children);
      loop$key_children_pairs = rest;
      loop$keyed_children = keyed_children$1;
      loop$children = children$1;
    }
  }
}
function extract_keyed_children(children) {
  return do_extract_keyed_children(
    children,
    empty2(),
    empty_list
  );
}
function element3(tag, attributes, children) {
  let $ = extract_keyed_children(children);
  let keyed_children;
  let children$1;
  keyed_children = $[0];
  children$1 = $[1];
  return element(
    "",
    identity2,
    "",
    tag,
    attributes,
    children$1,
    keyed_children,
    false,
    false
  );
}
function namespaced2(namespace, tag, attributes, children) {
  let $ = extract_keyed_children(children);
  let keyed_children;
  let children$1;
  keyed_children = $[0];
  children$1 = $[1];
  return element(
    "",
    identity2,
    namespace,
    tag,
    attributes,
    children$1,
    keyed_children,
    false,
    false
  );
}
function fragment2(children) {
  let $ = extract_keyed_children(children);
  let keyed_children;
  let children$1;
  keyed_children = $[0];
  children$1 = $[1];
  return fragment("", identity2, children$1, keyed_children);
}

// build/dev/javascript/lustre/lustre/vdom/virtualise.ffi.mjs
var virtualise = (root3) => {
  const rootMeta = insertMetadataChild(element_kind, null, root3, 0, null);
  let virtualisableRootChildren = 0;
  for (let child = root3.firstChild; child; child = child.nextSibling) {
    if (canVirtualiseNode(child)) virtualisableRootChildren += 1;
  }
  if (virtualisableRootChildren === 0) {
    const placeholder = document().createTextNode("");
    insertMetadataChild(text_kind, rootMeta, placeholder, 0, null);
    root3.replaceChildren(placeholder);
    return none2();
  }
  if (virtualisableRootChildren === 1) {
    const children2 = virtualiseChildNodes(rootMeta, root3);
    return children2.head[1];
  }
  const fragmentHead = document().createTextNode("");
  const fragmentMeta = insertMetadataChild(fragment_kind, rootMeta, fragmentHead, 0, null);
  const children = virtualiseChildNodes(fragmentMeta, root3);
  root3.insertBefore(fragmentHead, root3.firstChild);
  return fragment2(children);
};
var canVirtualiseNode = (node) => {
  switch (node.nodeType) {
    case ELEMENT_NODE:
      return true;
    case TEXT_NODE:
      return !!node.data;
    default:
      return false;
  }
};
var virtualiseNode = (meta2, node, key2, index4) => {
  if (!canVirtualiseNode(node)) {
    return null;
  }
  switch (node.nodeType) {
    case ELEMENT_NODE: {
      const childMeta = insertMetadataChild(element_kind, meta2, node, index4, key2);
      const tag = node.localName;
      const namespace = node.namespaceURI;
      const isHtmlElement = !namespace || namespace === NAMESPACE_HTML;
      if (isHtmlElement && INPUT_ELEMENTS.includes(tag)) {
        virtualiseInputEvents(tag, node);
      }
      const attributes = virtualiseAttributes(node);
      const children = virtualiseChildNodes(childMeta, node);
      const vnode = isHtmlElement ? element3(tag, attributes, children) : namespaced2(namespace, tag, attributes, children);
      return vnode;
    }
    case TEXT_NODE:
      insertMetadataChild(text_kind, meta2, node, index4, null);
      return text2(node.data);
    default:
      return null;
  }
};
var INPUT_ELEMENTS = ["input", "select", "textarea"];
var virtualiseInputEvents = (tag, node) => {
  const value2 = node.value;
  const checked = node.checked;
  if (tag === "input" && node.type === "checkbox" && !checked) return;
  if (tag === "input" && node.type === "radio" && !checked) return;
  if (node.type !== "checkbox" && node.type !== "radio" && !value2) return;
  queueMicrotask(() => {
    node.value = value2;
    node.checked = checked;
    node.dispatchEvent(new Event("input", { bubbles: true }));
    node.dispatchEvent(new Event("change", { bubbles: true }));
    if (document().activeElement !== node) {
      node.dispatchEvent(new Event("blur", { bubbles: true }));
    }
  });
};
var virtualiseChildNodes = (meta2, node) => {
  let children = null;
  let child = node.firstChild;
  let ptr = null;
  let index4 = 0;
  while (child) {
    const key2 = child.nodeType === ELEMENT_NODE ? child.getAttribute("data-lustre-key") : null;
    if (key2 != null) {
      child.removeAttribute("data-lustre-key");
    }
    const vnode = virtualiseNode(meta2, child, key2, index4);
    const next = child.nextSibling;
    if (vnode) {
      const list_node = new NonEmpty([key2 ?? "", vnode], null);
      if (ptr) {
        ptr = ptr.tail = list_node;
      } else {
        ptr = children = list_node;
      }
      index4 += 1;
    } else {
      node.removeChild(child);
    }
    child = next;
  }
  if (!ptr) return empty_list;
  ptr.tail = empty_list;
  return children;
};
var virtualiseAttributes = (node) => {
  let index4 = node.attributes.length;
  let attributes = empty_list;
  while (index4-- > 0) {
    const attr = node.attributes[index4];
    if (attr.name === "xmlns") {
      continue;
    }
    attributes = new NonEmpty(virtualiseAttribute(attr), attributes);
  }
  return attributes;
};
var virtualiseAttribute = (attr) => {
  const name = attr.localName;
  const value2 = attr.value;
  return attribute2(name, value2);
};

// build/dev/javascript/lustre/lustre/runtime/client/runtime.ffi.mjs
var is_browser = () => !!document();
var Runtime = class {
  constructor(root3, [model, effects], view2, update3) {
    this.root = root3;
    this.#model = model;
    this.#view = view2;
    this.#update = update3;
    this.root.addEventListener("context-request", (event4) => {
      if (!(event4.context && event4.callback)) return;
      if (!this.#contexts.has(event4.context)) return;
      event4.stopImmediatePropagation();
      const context = this.#contexts.get(event4.context);
      if (event4.subscribe) {
        const callbackRef = new WeakRef(event4.callback);
        const unsubscribe = () => {
          context.subscribers = context.subscribers.filter(
            (subscriber) => subscriber !== callbackRef
          );
        };
        context.subscribers.push([callbackRef, unsubscribe]);
        event4.callback(context.value, unsubscribe);
      } else {
        event4.callback(context.value);
      }
    });
    this.#reconciler = new Reconciler(this.root, (event4, path, name) => {
      const [events, result] = handle(this.#events, path, name, event4);
      this.#events = events;
      if (result.isOk()) {
        const handler = result[0];
        if (handler.stop_propagation) event4.stopPropagation();
        if (handler.prevent_default) event4.preventDefault();
        this.dispatch(handler.message, false);
      }
    });
    this.#vdom = virtualise(this.root);
    this.#events = new$3();
    this.#shouldFlush = true;
    this.#tick(effects);
  }
  // PUBLIC API ----------------------------------------------------------------
  root = null;
  dispatch(msg, immediate = false) {
    this.#shouldFlush ||= immediate;
    if (this.#shouldQueue) {
      this.#queue.push(msg);
    } else {
      const [model, effects] = this.#update(this.#model, msg);
      this.#model = model;
      this.#tick(effects);
    }
  }
  emit(event4, data) {
    const target2 = this.root.host ?? this.root;
    target2.dispatchEvent(
      new CustomEvent(event4, {
        detail: data,
        bubbles: true,
        composed: true
      })
    );
  }
  // Provide a context value for any child nodes that request it using the given
  // key. If the key already exists, any existing subscribers will be notified
  // of the change. Otherwise, we store the value and wait for any `context-request`
  // events to come in.
  provide(key2, value2) {
    if (!this.#contexts.has(key2)) {
      this.#contexts.set(key2, { value: value2, subscribers: [] });
    } else {
      const context = this.#contexts.get(key2);
      context.value = value2;
      for (let i = context.subscribers.length - 1; i >= 0; i--) {
        const [subscriberRef, unsubscribe] = context.subscribers[i];
        const subscriber = subscriberRef.deref();
        if (!subscriber) {
          context.subscribers.splice(i, 1);
          continue;
        }
        subscriber(value2, unsubscribe);
      }
    }
  }
  // PRIVATE API ---------------------------------------------------------------
  #model;
  #view;
  #update;
  #vdom;
  #events;
  #reconciler;
  #contexts = /* @__PURE__ */ new Map();
  #shouldQueue = false;
  #queue = [];
  #beforePaint = empty_list;
  #afterPaint = empty_list;
  #renderTimer = null;
  #shouldFlush = false;
  #actions = {
    dispatch: (msg, immediate) => this.dispatch(msg, immediate),
    emit: (event4, data) => this.emit(event4, data),
    select: () => {
    },
    root: () => this.root,
    provide: (key2, value2) => this.provide(key2, value2)
  };
  // A `#tick` is where we process effects and trigger any synchronous updates.
  // Once a tick has been processed a render will be scheduled if none is already.
  // p0
  #tick(effects) {
    this.#shouldQueue = true;
    while (true) {
      for (let list4 = effects.synchronous; list4.tail; list4 = list4.tail) {
        list4.head(this.#actions);
      }
      this.#beforePaint = listAppend(this.#beforePaint, effects.before_paint);
      this.#afterPaint = listAppend(this.#afterPaint, effects.after_paint);
      if (!this.#queue.length) break;
      [this.#model, effects] = this.#update(this.#model, this.#queue.shift());
    }
    this.#shouldQueue = false;
    if (this.#shouldFlush) {
      cancelAnimationFrame(this.#renderTimer);
      this.#render();
    } else if (!this.#renderTimer) {
      this.#renderTimer = requestAnimationFrame(() => {
        this.#render();
      });
    }
  }
  #render() {
    this.#shouldFlush = false;
    this.#renderTimer = null;
    const next = this.#view(this.#model);
    const { patch, events } = diff(this.#events, this.#vdom, next);
    this.#events = events;
    this.#vdom = next;
    this.#reconciler.push(patch);
    if (this.#beforePaint instanceof NonEmpty) {
      const effects = makeEffect(this.#beforePaint);
      this.#beforePaint = empty_list;
      queueMicrotask(() => {
        this.#shouldFlush = true;
        this.#tick(effects);
      });
    }
    if (this.#afterPaint instanceof NonEmpty) {
      const effects = makeEffect(this.#afterPaint);
      this.#afterPaint = empty_list;
      requestAnimationFrame(() => {
        this.#shouldFlush = true;
        this.#tick(effects);
      });
    }
  }
};
function makeEffect(synchronous) {
  return {
    synchronous,
    after_paint: empty_list,
    before_paint: empty_list
  };
}
function listAppend(a, b) {
  if (a instanceof Empty) {
    return b;
  } else if (b instanceof Empty) {
    return a;
  } else {
    return append(a, b);
  }
}

// build/dev/javascript/lustre/lustre/runtime/server/runtime.mjs
var EffectDispatchedMessage = class extends CustomType {
  constructor(message) {
    super();
    this.message = message;
  }
};
var EffectEmitEvent = class extends CustomType {
  constructor(name, data) {
    super();
    this.name = name;
    this.data = data;
  }
};
var SystemRequestedShutdown = class extends CustomType {
};

// build/dev/javascript/lustre/lustre/component.mjs
var Config2 = class extends CustomType {
  constructor(open_shadow_root, adopt_styles, delegates_focus, attributes, properties, contexts, is_form_associated, on_form_autofill, on_form_reset, on_form_restore) {
    super();
    this.open_shadow_root = open_shadow_root;
    this.adopt_styles = adopt_styles;
    this.delegates_focus = delegates_focus;
    this.attributes = attributes;
    this.properties = properties;
    this.contexts = contexts;
    this.is_form_associated = is_form_associated;
    this.on_form_autofill = on_form_autofill;
    this.on_form_reset = on_form_reset;
    this.on_form_restore = on_form_restore;
  }
};
function new$6(options) {
  let init2 = new Config2(
    true,
    true,
    false,
    empty_list,
    empty_list,
    empty_list,
    false,
    option_none,
    option_none,
    option_none
  );
  return fold(
    options,
    init2,
    (config, option) => {
      return option.apply(config);
    }
  );
}

// build/dev/javascript/lustre/lustre/runtime/client/spa.ffi.mjs
var Spa = class {
  #runtime;
  constructor(root3, [init2, effects], update3, view2) {
    this.#runtime = new Runtime(root3, [init2, effects], view2, update3);
  }
  send(message) {
    switch (message.constructor) {
      case EffectDispatchedMessage: {
        this.dispatch(message.message, false);
        break;
      }
      case EffectEmitEvent: {
        this.emit(message.name, message.data);
        break;
      }
      case SystemRequestedShutdown:
        break;
    }
  }
  dispatch(msg, immediate) {
    this.#runtime.dispatch(msg, immediate);
  }
  emit(event4, data) {
    this.#runtime.emit(event4, data);
  }
};
var start = ({ init: init2, update: update3, view: view2 }, selector, flags) => {
  if (!is_browser()) return new Error(new NotABrowser());
  const root3 = selector instanceof HTMLElement ? selector : document().querySelector(selector);
  if (!root3) return new Error(new ElementNotFound(selector));
  return new Ok(new Spa(root3, init2(flags), update3, view2));
};

// build/dev/javascript/lustre/lustre.mjs
var App = class extends CustomType {
  constructor(init2, update3, view2, config) {
    super();
    this.init = init2;
    this.update = update3;
    this.view = view2;
    this.config = config;
  }
};
var ElementNotFound = class extends CustomType {
  constructor(selector) {
    super();
    this.selector = selector;
  }
};
var NotABrowser = class extends CustomType {
};
function application(init2, update3, view2) {
  return new App(init2, update3, view2, new$6(empty_list));
}
function simple(init2, update3, view2) {
  let init$1 = (start_args) => {
    return [init2(start_args), none()];
  };
  let update$1 = (model, msg) => {
    return [update3(model, msg), none()];
  };
  return application(init$1, update$1, view2);
}
function start3(app, selector, start_args) {
  return guard(
    !is_browser(),
    new Error(new NotABrowser()),
    () => {
      return start(app, selector, start_args);
    }
  );
}

// build/dev/javascript/facet/facet/internal/flag.mjs
var Field = class extends CustomType {
  constructor(one, two) {
    super();
    this.one = one;
    this.two = two;
  }
};
var First = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Second = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
function present(flag2, field2) {
  if (flag2 instanceof First) {
    let field_one = field2.one;
    let first3 = flag2[0];
    return bitwise_and(first3, field_one) === first3;
  } else {
    let field_two = field2.two;
    let second2 = flag2[0];
    return bitwise_and(second2, field_two) === second2;
  }
}
function add3(field2, flag2) {
  if (flag2 instanceof First) {
    let first3 = flag2[0];
    return new Field(bitwise_or(first3, field2.one), field2.two);
  } else {
    let second2 = flag2[0];
    return new Field(field2.one, bitwise_or(second2, field2.two));
  }
}
function merge2(field1, field2) {
  return new Field(
    bitwise_or(field1.one, field2.one),
    bitwise_or(field1.two, field2.two)
  );
}
function flag(i) {
  let $ = i > 31;
  if ($) {
    return new Second(bitwise_shift_left(i - 32, 1));
  } else {
    return new First(bitwise_shift_left(i, 1));
  }
}
function padding() {
  return flag(2);
}
function spacing() {
  return flag(3);
}
function font_size() {
  return flag(4);
}
function font_family() {
  return flag(5);
}
function width() {
  return flag(6);
}
function height() {
  return flag(7);
}
function bg_color() {
  return flag(8);
}
function border_style() {
  return flag(11);
}
function font_color() {
  return flag(14);
}
function border_round() {
  return flag(17);
}
function cursor() {
  return flag(21);
}
function border_width() {
  return flag(27);
}
function y_align() {
  return flag(29);
}
function x_align() {
  return flag(30);
}
function height_content() {
  return flag(36);
}
function height_fill() {
  return flag(37);
}
function width_content() {
  return flag(38);
}
function width_fill() {
  return flag(39);
}
function align_right() {
  return flag(40);
}
function align_bottom() {
  return flag(41);
}
function center_x() {
  return flag(42);
}
function center_y() {
  return flag(43);
}
function width_between() {
  return flag(44);
}
function height_between() {
  return flag(45);
}
var none3 = /* @__PURE__ */ new Field(0, 0);

// build/dev/javascript/gleam_stdlib/gleam/pair.mjs
function first2(pair) {
  let a;
  a = pair[0];
  return a;
}
function second(pair) {
  let a;
  a = pair[1];
  return a;
}

// build/dev/javascript/facet/facet/internal/style.mjs
var Class = class extends CustomType {
  constructor(name, rules2) {
    super();
    this.name = name;
    this.rules = rules2;
  }
};
var Prop = class extends CustomType {
  constructor(name, value2) {
    super();
    this.name = name;
    this.value = value2;
  }
};
var Child = class extends CustomType {
  constructor(name, rules2) {
    super();
    this.name = name;
    this.rules = rules2;
  }
};
var AllChildren = class extends CustomType {
  constructor(name, rules2) {
    super();
    this.name = name;
    this.rules = rules2;
  }
};
var Supports = class extends CustomType {
  constructor(prop, value2, rules2) {
    super();
    this.prop = prop;
    this.value = value2;
    this.rules = rules2;
  }
};
var Descriptor = class extends CustomType {
  constructor(name, rules2) {
    super();
    this.name = name;
    this.rules = rules2;
  }
};
var Adjacent = class extends CustomType {
  constructor(name, rules2) {
    super();
    this.name = name;
    this.rules = rules2;
  }
};
var Batch2 = class extends CustomType {
  constructor(rules2) {
    super();
    this.rules = rules2;
  }
};
var Top = class extends CustomType {
};
var Bottom = class extends CustomType {
};
var Right = class extends CustomType {
};
var Left = class extends CustomType {
};
var CenterX = class extends CustomType {
};
var CenterY = class extends CustomType {
};
var Above = class extends CustomType {
};
var Below = class extends CustomType {
};
var OnRight = class extends CustomType {
};
var OnLeft = class extends CustomType {
};
var Within = class extends CustomType {
};
var Behind = class extends CustomType {
};
var Self = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Content = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Intermediate = class extends CustomType {
  constructor(selector, props, closing, others) {
    super();
    this.selector = selector;
    this.props = props;
    this.closing = closing;
    this.others = others;
  }
};
function alignments() {
  return toList([
    new Top(),
    new Bottom(),
    new Right(),
    new Left(),
    new CenterX(),
    new CenterY()
  ]);
}
function locations() {
  return toList([
    new Above(),
    new Below(),
    new OnRight(),
    new OnLeft(),
    new Within(),
    new Behind()
  ]);
}
function dot(c) {
  return "." + c;
}
function empty_intermediate(selector, closing) {
  return new Intermediate(selector, toList([]), closing, toList([]));
}
function render_rules(parent, rules_to_render) {
  let generate_intermediates = (rendered, rule) => {
    if (rule instanceof Prop) {
      let name = rule.name;
      let val = rule.value;
      return new Intermediate(
        rendered.selector,
        prepend([name, val], rendered.props),
        rendered.closing,
        rendered.others
      );
    } else if (rule instanceof Child) {
      let child = rule.name;
      let child_rules = rule.rules;
      return new Intermediate(
        rendered.selector,
        rendered.props,
        rendered.closing,
        prepend(
          render_rules(
            empty_intermediate(rendered.selector + " > " + child, ""),
            child_rules
          ),
          rendered.others
        )
      );
    } else if (rule instanceof AllChildren) {
      let child = rule.name;
      let child_rules = rule.rules;
      return new Intermediate(
        rendered.selector,
        rendered.props,
        rendered.closing,
        prepend(
          render_rules(
            empty_intermediate(rendered.selector + " " + child, ""),
            child_rules
          ),
          rendered.others
        )
      );
    } else if (rule instanceof Supports) {
      let prop = rule.prop;
      let value2 = rule.value;
      let props = rule.rules;
      return new Intermediate(
        rendered.selector,
        rendered.props,
        rendered.closing,
        prepend(
          new Intermediate(
            "@supports (" + prop + ":" + value2 + ") {" + rendered.selector,
            props,
            "\n}",
            toList([])
          ),
          rendered.others
        )
      );
    } else if (rule instanceof Descriptor) {
      let descriptor = rule.name;
      let descriptor_rules = rule.rules;
      return new Intermediate(
        rendered.selector,
        rendered.props,
        rendered.closing,
        prepend(
          render_rules(
            empty_intermediate(rendered.selector + descriptor, ""),
            descriptor_rules
          ),
          rendered.others
        )
      );
    } else if (rule instanceof Adjacent) {
      let selector = rule.name;
      let adj_rules = rule.rules;
      return new Intermediate(
        rendered.selector,
        rendered.props,
        rendered.closing,
        prepend(
          render_rules(
            empty_intermediate(rendered.selector + " + " + selector, ""),
            adj_rules
          ),
          rendered.others
        )
      );
    } else {
      let batched = rule.rules;
      return new Intermediate(
        rendered.selector,
        rendered.props,
        rendered.closing,
        prepend(
          render_rules(empty_intermediate(rendered.selector, ""), batched),
          rendered.others
        )
      );
    }
  };
  return fold_right(rules_to_render, parent, generate_intermediates);
}
function render_values(values4) {
  let _pipe = values4;
  let _pipe$1 = map2(
    _pipe,
    (a) => {
      let x = a[0];
      let y = a[1];
      return "  " + x + ": " + y + ";";
    }
  );
  return join(_pipe$1, "\n");
}
function render_class(rule) {
  let $ = rule.props;
  if ($ instanceof Empty) {
    return "";
  } else {
    return rule.selector + " {\n" + render_values(rule.props) + rule.closing + "\n}";
  }
}
function render_intermediate(rule) {
  return render_class(rule) + (() => {
    let _pipe = map2(rule.others, render_intermediate);
    return join(_pipe, "\n");
  })();
}
function render_compact(style_classes) {
  let render_values$1 = (values4) => {
    let _pipe2 = values4;
    let _pipe$12 = map2(
      _pipe2,
      (a) => {
        let x = a[0];
        let y = a[1];
        return x + ":" + y + ";";
      }
    );
    return concat2(_pipe$12);
  };
  let render_class$1 = (rule) => {
    let $ = rule.props;
    if ($ instanceof Empty) {
      return "";
    } else {
      return rule.selector + "{" + render_values$1(rule.props) + rule.closing + "}";
    }
  };
  let render_intermediate$1 = (rule) => {
    return render_class$1(rule) + (() => {
      let _pipe2 = map2(rule.others, render_intermediate);
      return concat2(_pipe2);
    })();
  };
  let _pipe = style_classes;
  let _pipe$1 = fold_right(
    _pipe,
    toList([]),
    (existing, class$2) => {
      let name;
      let rules$1;
      name = class$2.name;
      rules$1 = class$2.rules;
      return append(
        toList([render_rules(empty_intermediate(name, ""), rules$1)]),
        existing
      );
    }
  );
  let _pipe$2 = map2(_pipe$1, render_intermediate$1);
  return concat2(_pipe$2);
}
function input_text_reset() {
  return '\ninput[type="search"],\ninput[type="search"]::-webkit-search-decoration,\ninput[type="search"]::-webkit-search-cancel-button,\ninput[type="search"]::-webkit-search-results-button,\ninput[type="search"]::-webkit-search-results-decoration {\n  -webkit-appearance:none;\n}\n';
}
function font_variant(var$) {
  return toList([
    new Class(
      ".v-" + var$,
      toList([new Prop("font-feature-settings", '"' + var$ + '"')])
    ),
    new Class(
      ".v-" + var$ + "-off",
      toList([new Prop("font-feature-settings", '"' + var$ + '" 0')])
    )
  ]);
}
function common_values() {
  return flatten(
    toList([
      map2(
        range(0, 6),
        (x) => {
          return new Class(
            ".border-" + to_string(x),
            toList([new Prop("border-width", to_string(x) + "px")])
          );
        }
      ),
      map2(
        range(8, 32),
        (i) => {
          return new Class(
            ".font-size-" + to_string(i),
            toList([new Prop("font-size", to_string(i) + "px")])
          );
        }
      ),
      map2(
        range(0, 24),
        (i) => {
          return new Class(
            ".p-" + to_string(i),
            toList([new Prop("padding", to_string(i) + "px")])
          );
        }
      ),
      toList([
        new Class(".v-smcp", toList([new Prop("font-variant", "small-caps")])),
        new Class(".v-smcp-off", toList([new Prop("font-variant", "normal")]))
      ]),
      flatten(
        toList([
          font_variant("zero"),
          font_variant("onum"),
          font_variant("liga"),
          font_variant("dlig"),
          font_variant("ordn"),
          font_variant("tnum"),
          font_variant("afrc"),
          font_variant("frac")
        ])
      )
    ])
  );
}
var classes_root = "ui";
var classes_any = "s";
function explainer() {
  return "\n.explain {\n    border: 6px solid rgb(174, 121, 15) !important;\n}\n.explain > ." + classes_any + " {\n    border: 4px dashed rgb(0, 151, 167) !important;\n}\n\n.ctr {\n    border: none !important;\n}\n.explain > .ctr > ." + classes_any + " {\n    border: 4px dashed rgb(0, 151, 167) !important;\n}\n";
}
var classes_single = "e";
var classes_row = "r";
var classes_column = "c";
var classes_page = "pg";
var classes_paragraph = "p";
var classes_text = "t";
var classes_grid = "g";
var classes_image_container = "ic";
var classes_wrapped = "wrp";
var classes_width_fill = "wf";
var classes_width_content = "wc";
var classes_width_exact = "we";
var classes_width_fill_portion = "wfp";
var classes_height_fill = "hf";
var classes_height_content = "hc";
var classes_height_exact = "he";
var classes_height_fill_portion = "hfp";
var classes_se_button = "sbt";
var classes_nearby = "nb";
var classes_above = "a";
var classes_below = "b";
var classes_on_right = "or";
var classes_on_left = "ol";
var classes_in_front = "fr";
var classes_behind = "bh";
var classes_has_behind = "hbh";
var classes_align_top = "at";
var classes_align_bottom = "ab";
var classes_align_right = "ar";
var classes_align_left = "al";
var classes_align_center_x = "cx";
var classes_align_center_y = "cy";
function self_name(desc) {
  let $ = desc[0];
  if ($ instanceof Top) {
    return dot(classes_align_top);
  } else if ($ instanceof Bottom) {
    return dot(classes_align_bottom);
  } else if ($ instanceof Right) {
    return dot(classes_align_right);
  } else if ($ instanceof Left) {
    return dot(classes_align_left);
  } else if ($ instanceof CenterX) {
    return dot(classes_align_center_x);
  } else {
    return dot(classes_align_center_y);
  }
}
function grid_alignments(values4) {
  let create_description = (alignment) => {
    return toList([
      new Child(
        dot(classes_any),
        toList([
          new Descriptor(self_name(new Self(alignment)), values4(alignment))
        ])
      )
    ]);
  };
  let _pipe = alignments();
  let _pipe$1 = flat_map(_pipe, create_description);
  return new Batch2(_pipe$1);
}
var classes_aligned_horizontally = "ah";
var classes_aligned_vertically = "av";
var classes_space_evenly = "sev";
var classes_container = "ctr";
var classes_align_container_right = "acr";
var classes_align_container_bottom = "acb";
var classes_align_container_center_x = "accx";
var classes_align_container_center_y = "accy";
var classes_content_top = "ct";
var classes_content_bottom = "cb";
var classes_content_right = "cr";
var classes_content_left = "cl";
var classes_content_center_x = "ccx";
var classes_content_center_y = "ccy";
function content_name(desc) {
  let $ = desc[0];
  if ($ instanceof Top) {
    return dot(classes_content_top);
  } else if ($ instanceof Bottom) {
    return dot(classes_content_bottom);
  } else if ($ instanceof Right) {
    return dot(classes_content_right);
  } else if ($ instanceof Left) {
    return dot(classes_content_left);
  } else if ($ instanceof CenterX) {
    return dot(classes_content_center_x);
  } else {
    return dot(classes_content_center_y);
  }
}
function describe_alignment(values4) {
  let create_description = (alignment) => {
    let $ = values4(alignment);
    let content;
    let indiv;
    content = $[0];
    indiv = $[1];
    return toList([
      new Descriptor(content_name(new Content(alignment)), content),
      new Child(
        dot(classes_any),
        toList([new Descriptor(self_name(new Self(alignment)), indiv)])
      )
    ]);
  };
  let _pipe = alignments();
  let _pipe$1 = flat_map(_pipe, create_description);
  return new Batch2(_pipe$1);
}
function el_description() {
  return toList([
    new Prop("display", "flex"),
    new Prop("flex-direction", "column"),
    new Prop("white-space", "pre"),
    new Descriptor(
      dot(classes_has_behind),
      toList([
        new Prop("z-index", "0"),
        new Child(dot(classes_behind), toList([new Prop("z-index", "-1")]))
      ])
    ),
    new Descriptor(
      dot(classes_se_button),
      toList([
        new Child(
          dot(classes_text),
          toList([
            new Descriptor(
              dot(classes_height_fill),
              toList([new Prop("flex-grow", "0")])
            ),
            new Descriptor(
              dot(classes_width_fill),
              toList([new Prop("align-self", "auto !important")])
            )
          ])
        )
      ])
    ),
    new Child(dot(classes_height_content), toList([new Prop("height", "auto")])),
    new Child(
      dot(classes_height_fill),
      toList([new Prop("flex-grow", "100000")])
    ),
    new Child(dot(classes_width_fill), toList([new Prop("width", "100%")])),
    new Child(
      dot(classes_width_fill_portion),
      toList([new Prop("width", "100%")])
    ),
    new Child(
      dot(classes_width_content),
      toList([new Prop("align-self", "flex-start")])
    ),
    describe_alignment(
      (alignment) => {
        if (alignment instanceof Top) {
          return [
            toList([new Prop("justify-content", "flex-start")]),
            toList([
              new Prop("margin-bottom", "auto !important"),
              new Prop("margin-top", "0 !important")
            ])
          ];
        } else if (alignment instanceof Bottom) {
          return [
            toList([new Prop("justify-content", "flex-end")]),
            toList([
              new Prop("margin-top", "auto !important"),
              new Prop("margin-bottom", "0 !important")
            ])
          ];
        } else if (alignment instanceof Right) {
          return [
            toList([new Prop("align-items", "flex-end")]),
            toList([new Prop("align-self", "flex-end")])
          ];
        } else if (alignment instanceof Left) {
          return [
            toList([new Prop("align-items", "flex-start")]),
            toList([new Prop("align-self", "flex-start")])
          ];
        } else if (alignment instanceof CenterX) {
          return [
            toList([new Prop("align-items", "center")]),
            toList([new Prop("align-self", "center")])
          ];
        } else {
          return [
            toList([
              new Child(
                dot(classes_any),
                toList([
                  new Prop("margin-top", "auto"),
                  new Prop("margin-bottom", "auto")
                ])
              )
            ]),
            toList([
              new Prop("margin-top", "auto !important"),
              new Prop("margin-bottom", "auto !important")
            ])
          ];
        }
      }
    )
  ]);
}
var classes_no_text_selection = "notxt";
var classes_cursor_pointer = "cptr";
var classes_cursor_text = "ctxt";
var classes_pass_pointer_events = "ppe";
var classes_capture_pointer_events = "cpe";
var classes_transparent = "clr";
var classes_opaque = "oq";
var classes_hover = "hv";
var classes_focus = "fcs";
var classes_focused_within = "focus-within";
var classes_active = "atv";
var classes_scrollbars = "sb";
var classes_scrollbars_x = "sbx";
var classes_scrollbars_y = "sby";
var classes_clip = "cp";
var classes_clip_x = "cpx";
var classes_clip_y = "cpy";
var classes_border_none = "bn";
var classes_border_dashed = "bd";
var classes_border_dotted = "bdt";
var classes_border_solid = "bs";
var classes_size_by_capital = "cap";
var classes_full_size = "fs";
var classes_text_thin = "w1";
var classes_text_extra_light = "w2";
var classes_text_light = "w3";
var classes_text_normal_weight = "w4";
var classes_text_medium = "w5";
var classes_text_semi_bold = "w6";
var classes_bold = "w7";
var classes_text_extra_bold = "w8";
var classes_text_heavy = "w9";
var classes_italic = "i";
var classes_strike = "sk";
var classes_underline = "u";
var classes_text_unitalicized = "tun";
var classes_text_justify = "tj";
var classes_text_justify_all = "tja";
var classes_text_center = "tc";
var classes_text_right = "tr";
var classes_text_left = "tl";
var classes_transition = "ts";
var classes_input_text = "it";
var classes_input_multiline = "iml";
var classes_input_multiline_parent = "imlp";
var classes_input_multiline_filler = "imlf";
var classes_input_multiline_wrapper = "implw";
var classes_input_label = "lbl";
var classes_link = "lnk";
function base_sheet() {
  return toList([
    new Class(
      "html,body",
      toList([
        new Prop("height", "100%"),
        new Prop("padding", "0"),
        new Prop("margin", "0")
      ])
    ),
    new Class(
      dot(classes_any) + dot(classes_single) + dot(classes_image_container),
      toList([
        new Prop("display", "block"),
        new Descriptor(
          dot(classes_height_fill),
          toList([
            new Child(
              "img",
              toList([
                new Prop("max-height", "100%"),
                new Prop("object-fit", "cover")
              ])
            )
          ])
        ),
        new Descriptor(
          dot(classes_width_fill),
          toList([
            new Child(
              "img",
              toList([
                new Prop("max-width", "100%"),
                new Prop("object-fit", "cover")
              ])
            )
          ])
        )
      ])
    ),
    new Class(
      dot(classes_any) + ":focus",
      toList([new Prop("outline", "none")])
    ),
    new Class(
      dot(classes_root),
      toList([
        new Prop("width", "100%"),
        new Prop("height", "auto"),
        new Prop("min-height", "100%"),
        new Prop("z-index", "0"),
        new Descriptor(
          dot(classes_any) + dot(classes_height_fill),
          toList([
            new Prop("height", "100%"),
            new Child(
              dot(classes_height_fill),
              toList([new Prop("height", "100%")])
            )
          ])
        ),
        new Child(
          dot(classes_in_front),
          toList([
            new Descriptor(
              dot(classes_nearby),
              toList([new Prop("position", "fixed"), new Prop("z-index", "20")])
            )
          ])
        )
      ])
    ),
    new Class(
      dot(classes_nearby),
      toList([
        new Prop("position", "relative"),
        new Prop("border", "none"),
        new Prop("display", "flex"),
        new Prop("flex-direction", "row"),
        new Prop("flex-basis", "auto"),
        new Descriptor(dot(classes_single), el_description()),
        new Batch2(
          map2(
            locations(),
            (loc) => {
              if (loc instanceof Above) {
                return new Descriptor(
                  dot(classes_above),
                  toList([
                    new Prop("position", "absolute"),
                    new Prop("bottom", "100%"),
                    new Prop("left", "0"),
                    new Prop("width", "100%"),
                    new Prop("z-index", "20"),
                    new Prop("margin", "0 !important"),
                    new Child(
                      dot(classes_height_fill),
                      toList([new Prop("height", "auto")])
                    ),
                    new Child(
                      dot(classes_width_fill),
                      toList([new Prop("width", "100%")])
                    ),
                    new Prop("pointer-events", "none"),
                    new Child("*", toList([new Prop("pointer-events", "auto")]))
                  ])
                );
              } else if (loc instanceof Below) {
                return new Descriptor(
                  dot(classes_below),
                  toList([
                    new Prop("position", "absolute"),
                    new Prop("bottom", "0"),
                    new Prop("left", "0"),
                    new Prop("height", "0"),
                    new Prop("width", "100%"),
                    new Prop("z-index", "20"),
                    new Prop("margin", "0 !important"),
                    new Prop("pointer-events", "none"),
                    new Child("*", toList([new Prop("pointer-events", "auto")])),
                    new Child(
                      dot(classes_height_fill),
                      toList([new Prop("height", "auto")])
                    )
                  ])
                );
              } else if (loc instanceof OnRight) {
                return new Descriptor(
                  dot(classes_on_right),
                  toList([
                    new Prop("position", "absolute"),
                    new Prop("left", "100%"),
                    new Prop("top", "0"),
                    new Prop("height", "100%"),
                    new Prop("margin", "0 !important"),
                    new Prop("z-index", "20"),
                    new Prop("pointer-events", "none"),
                    new Child("*", toList([new Prop("pointer-events", "auto")]))
                  ])
                );
              } else if (loc instanceof OnLeft) {
                return new Descriptor(
                  dot(classes_on_left),
                  toList([
                    new Prop("position", "absolute"),
                    new Prop("right", "100%"),
                    new Prop("top", "0"),
                    new Prop("height", "100%"),
                    new Prop("margin", "0 !important"),
                    new Prop("z-index", "20"),
                    new Prop("pointer-events", "none"),
                    new Child("*", toList([new Prop("pointer-events", "auto")]))
                  ])
                );
              } else if (loc instanceof Within) {
                return new Descriptor(
                  dot(classes_in_front),
                  toList([
                    new Prop("position", "absolute"),
                    new Prop("width", "100%"),
                    new Prop("height", "100%"),
                    new Prop("left", "0"),
                    new Prop("top", "0"),
                    new Prop("margin", "0 !important"),
                    new Prop("pointer-events", "none"),
                    new Child("*", toList([new Prop("pointer-events", "auto")]))
                  ])
                );
              } else {
                return new Descriptor(
                  dot(classes_behind),
                  toList([
                    new Prop("position", "absolute"),
                    new Prop("width", "100%"),
                    new Prop("height", "100%"),
                    new Prop("left", "0"),
                    new Prop("top", "0"),
                    new Prop("margin", "0 !important"),
                    new Prop("z-index", "0"),
                    new Prop("pointer-events", "none"),
                    new Child("*", toList([new Prop("pointer-events", "auto")]))
                  ])
                );
              }
            }
          )
        )
      ])
    ),
    new Class(
      dot(classes_any),
      toList([
        new Prop("position", "relative"),
        new Prop("border", "none"),
        new Prop("flex-shrink", "0"),
        new Prop("display", "flex"),
        new Prop("flex-direction", "row"),
        new Prop("flex-basis", "auto"),
        new Prop("resize", "none"),
        new Prop("font-feature-settings", "inherit"),
        new Prop("box-sizing", "border-box"),
        new Prop("margin", "0"),
        new Prop("padding", "0"),
        new Prop("border-width", "0"),
        new Prop("border-style", "solid"),
        new Prop("font-size", "inherit"),
        new Prop("color", "inherit"),
        new Prop("font-family", "inherit"),
        new Prop("line-height", "1"),
        new Prop("font-weight", "inherit"),
        new Prop("text-decoration", "none"),
        new Prop("font-style", "inherit"),
        new Descriptor(
          dot(classes_wrapped),
          toList([new Prop("flex-wrap", "wrap")])
        ),
        new Descriptor(
          dot(classes_no_text_selection),
          toList([
            new Prop("-moz-user-select", "none"),
            new Prop("-webkit-user-select", "none"),
            new Prop("-ms-user-select", "none"),
            new Prop("user-select", "none")
          ])
        ),
        new Descriptor(
          dot(classes_cursor_pointer),
          toList([new Prop("cursor", "pointer")])
        ),
        new Descriptor(
          dot(classes_cursor_text),
          toList([new Prop("cursor", "text")])
        ),
        new Descriptor(
          dot(classes_pass_pointer_events),
          toList([new Prop("pointer-events", "none !important")])
        ),
        new Descriptor(
          dot(classes_capture_pointer_events),
          toList([new Prop("pointer-events", "auto !important")])
        ),
        new Descriptor(
          dot(classes_transparent),
          toList([new Prop("opacity", "0")])
        ),
        new Descriptor(dot(classes_opaque), toList([new Prop("opacity", "1")])),
        new Descriptor(
          dot(classes_hover + classes_transparent) + ":hover",
          toList([new Prop("opacity", "0")])
        ),
        new Descriptor(
          dot(classes_hover + classes_opaque) + ":hover",
          toList([new Prop("opacity", "1")])
        ),
        new Descriptor(
          dot(classes_focus + classes_transparent) + ":focus",
          toList([new Prop("opacity", "0")])
        ),
        new Descriptor(
          dot(classes_focus + classes_opaque) + ":focus",
          toList([new Prop("opacity", "1")])
        ),
        new Descriptor(
          dot(classes_active + classes_transparent) + ":active",
          toList([new Prop("opacity", "0")])
        ),
        new Descriptor(
          dot(classes_active + classes_opaque) + ":active",
          toList([new Prop("opacity", "1")])
        ),
        new Descriptor(
          dot(classes_transition),
          toList([
            new Prop(
              "transition",
              join(
                map2(
                  toList([
                    "transform",
                    "opacity",
                    "filter",
                    "background-color",
                    "color",
                    "font-size"
                  ]),
                  (x) => {
                    return x + " 160ms";
                  }
                ),
                ", "
              )
            )
          ])
        ),
        new Descriptor(
          dot(classes_scrollbars),
          toList([new Prop("overflow", "auto"), new Prop("flex-shrink", "1")])
        ),
        new Descriptor(
          dot(classes_scrollbars_x),
          toList([
            new Prop("overflow-x", "auto"),
            new Descriptor(
              dot(classes_row),
              toList([new Prop("flex-shrink", "1")])
            )
          ])
        ),
        new Descriptor(
          dot(classes_scrollbars_y),
          toList([
            new Prop("overflow-y", "auto"),
            new Descriptor(
              dot(classes_column),
              toList([new Prop("flex-shrink", "1")])
            ),
            new Descriptor(
              dot(classes_single),
              toList([new Prop("flex-shrink", "1")])
            )
          ])
        ),
        new Descriptor(
          dot(classes_clip),
          toList([new Prop("overflow", "hidden")])
        ),
        new Descriptor(
          dot(classes_clip_x),
          toList([new Prop("overflow-x", "hidden")])
        ),
        new Descriptor(
          dot(classes_clip_y),
          toList([new Prop("overflow-y", "hidden")])
        ),
        new Descriptor(
          dot(classes_width_content),
          toList([new Prop("width", "auto")])
        ),
        new Descriptor(
          dot(classes_border_none),
          toList([new Prop("border-width", "0")])
        ),
        new Descriptor(
          dot(classes_border_dashed),
          toList([new Prop("border-style", "dashed")])
        ),
        new Descriptor(
          dot(classes_border_dotted),
          toList([new Prop("border-style", "dotted")])
        ),
        new Descriptor(
          dot(classes_border_solid),
          toList([new Prop("border-style", "solid")])
        ),
        new Descriptor(
          dot(classes_text),
          toList([
            new Prop("white-space", "pre"),
            new Prop("display", "inline-block")
          ])
        ),
        new Descriptor(
          dot(classes_input_text),
          toList([
            new Prop("line-height", "1.05"),
            new Prop("background", "transparent"),
            new Prop("text-align", "inherit")
          ])
        ),
        new Descriptor(dot(classes_single), el_description()),
        new Descriptor(
          dot(classes_row),
          toList([
            new Prop("display", "flex"),
            new Prop("flex-direction", "row"),
            new Child(
              dot(classes_any),
              toList([
                new Prop("flex-basis", "0%"),
                new Descriptor(
                  dot(classes_width_exact),
                  toList([new Prop("flex-basis", "auto")])
                ),
                new Descriptor(
                  dot(classes_link),
                  toList([new Prop("flex-basis", "auto")])
                )
              ])
            ),
            new Child(
              dot(classes_height_fill),
              toList([new Prop("align-self", "stretch !important")])
            ),
            new Child(
              dot(classes_height_fill_portion),
              toList([new Prop("align-self", "stretch !important")])
            ),
            new Child(
              dot(classes_width_fill),
              toList([new Prop("flex-grow", "100000")])
            ),
            new Child(
              dot(classes_container),
              toList([
                new Prop("flex-grow", "0"),
                new Prop("flex-basis", "auto"),
                new Prop("align-self", "stretch")
              ])
            ),
            new Child(
              "u:first-of-type." + classes_align_container_right,
              toList([new Prop("flex-grow", "1")])
            ),
            new Child(
              "s:first-of-type." + classes_align_container_center_x,
              toList([
                new Prop("flex-grow", "1"),
                new Child(
                  dot(classes_align_center_x),
                  toList([new Prop("margin-left", "auto !important")])
                )
              ])
            ),
            new Child(
              "s:last-of-type." + classes_align_container_center_x,
              toList([
                new Prop("flex-grow", "1"),
                new Child(
                  dot(classes_align_center_x),
                  toList([new Prop("margin-right", "auto !important")])
                )
              ])
            ),
            new Child(
              "s:only-of-type." + classes_align_container_center_x,
              toList([
                new Prop("flex-grow", "1"),
                new Child(
                  dot(classes_align_center_y),
                  toList([
                    new Prop("margin-top", "auto !important"),
                    new Prop("margin-bottom", "auto !important")
                  ])
                )
              ])
            ),
            new Child(
              "s:last-of-type." + classes_align_container_center_x + " ~ u",
              toList([new Prop("flex-grow", "0")])
            ),
            new Child(
              "u:first-of-type." + classes_align_container_right + " ~ s." + classes_align_container_center_x,
              toList([new Prop("flex-grow", "0")])
            ),
            describe_alignment(
              (alignment) => {
                if (alignment instanceof Top) {
                  return [
                    toList([new Prop("align-items", "flex-start")]),
                    toList([new Prop("align-self", "flex-start")])
                  ];
                } else if (alignment instanceof Bottom) {
                  return [
                    toList([new Prop("align-items", "flex-end")]),
                    toList([new Prop("align-self", "flex-end")])
                  ];
                } else if (alignment instanceof Right) {
                  return [
                    toList([new Prop("justify-content", "flex-end")]),
                    toList([])
                  ];
                } else if (alignment instanceof Left) {
                  return [
                    toList([new Prop("justify-content", "flex-start")]),
                    toList([])
                  ];
                } else if (alignment instanceof CenterX) {
                  return [
                    toList([new Prop("justify-content", "center")]),
                    toList([])
                  ];
                } else {
                  return [
                    toList([new Prop("align-items", "center")]),
                    toList([new Prop("align-self", "center")])
                  ];
                }
              }
            ),
            new Descriptor(
              dot(classes_space_evenly),
              toList([new Prop("justify-content", "space-between")])
            ),
            new Descriptor(
              dot(classes_input_label),
              toList([new Prop("align-items", "baseline")])
            )
          ])
        ),
        new Descriptor(
          dot(classes_column),
          toList([
            new Prop("display", "flex"),
            new Prop("flex-direction", "column"),
            new Child(
              dot(classes_any),
              toList([
                new Prop("flex-basis", "0px"),
                new Prop("min-height", "min-content"),
                new Descriptor(
                  dot(classes_height_exact),
                  toList([new Prop("flex-basis", "auto")])
                )
              ])
            ),
            new Child(
              dot(classes_height_fill),
              toList([new Prop("flex-grow", "100000")])
            ),
            new Child(
              dot(classes_width_fill),
              toList([new Prop("width", "100%")])
            ),
            new Child(
              dot(classes_width_fill_portion),
              toList([new Prop("width", "100%")])
            ),
            new Child(
              dot(classes_width_content),
              toList([new Prop("align-self", "flex-start")])
            ),
            new Child(
              "u:first-of-type." + classes_align_container_bottom,
              toList([new Prop("flex-grow", "1")])
            ),
            new Child(
              "s:first-of-type." + classes_align_container_center_y,
              toList([
                new Prop("flex-grow", "1"),
                new Child(
                  dot(classes_align_center_y),
                  toList([
                    new Prop("margin-top", "auto !important"),
                    new Prop("margin-bottom", "0 !important")
                  ])
                )
              ])
            ),
            new Child(
              "s:last-of-type." + classes_align_container_center_y,
              toList([
                new Prop("flex-grow", "1"),
                new Child(
                  dot(classes_align_center_y),
                  toList([
                    new Prop("margin-bottom", "auto !important"),
                    new Prop("margin-top", "0 !important")
                  ])
                )
              ])
            ),
            new Child(
              "s:only-of-type." + classes_align_container_center_y,
              toList([
                new Prop("flex-grow", "1"),
                new Child(
                  dot(classes_align_center_y),
                  toList([
                    new Prop("margin-top", "auto !important"),
                    new Prop("margin-bottom", "auto !important")
                  ])
                )
              ])
            ),
            new Child(
              "s:last-of-type." + classes_align_container_center_y + " ~ u",
              toList([new Prop("flex-grow", "0")])
            ),
            new Child(
              "u:first-of-type." + classes_align_container_bottom + " ~ s." + classes_align_container_center_y,
              toList([new Prop("flex-grow", "0")])
            ),
            describe_alignment(
              (alignment) => {
                if (alignment instanceof Top) {
                  return [
                    toList([new Prop("justify-content", "flex-start")]),
                    toList([new Prop("margin-bottom", "auto")])
                  ];
                } else if (alignment instanceof Bottom) {
                  return [
                    toList([new Prop("justify-content", "flex-end")]),
                    toList([new Prop("margin-top", "auto")])
                  ];
                } else if (alignment instanceof Right) {
                  return [
                    toList([new Prop("align-items", "flex-end")]),
                    toList([new Prop("align-self", "flex-end")])
                  ];
                } else if (alignment instanceof Left) {
                  return [
                    toList([new Prop("align-items", "flex-start")]),
                    toList([new Prop("align-self", "flex-start")])
                  ];
                } else if (alignment instanceof CenterX) {
                  return [
                    toList([new Prop("align-items", "center")]),
                    toList([new Prop("align-self", "center")])
                  ];
                } else {
                  return [
                    toList([new Prop("justify-content", "center")]),
                    toList([])
                  ];
                }
              }
            ),
            new Child(
              dot(classes_container),
              toList([
                new Prop("flex-grow", "0"),
                new Prop("flex-basis", "auto"),
                new Prop("width", "100%"),
                new Prop("align-self", "stretch !important")
              ])
            ),
            new Descriptor(
              dot(classes_space_evenly),
              toList([new Prop("justify-content", "space-between")])
            )
          ])
        ),
        new Descriptor(
          dot(classes_grid),
          toList([
            new Prop("display", "-ms-grid"),
            new Child(
              ".gp",
              toList([
                new Child(dot(classes_any), toList([new Prop("width", "100%")]))
              ])
            ),
            new Supports("display", "grid", toList([["display", "grid"]])),
            grid_alignments(
              (alignment) => {
                if (alignment instanceof Top) {
                  return toList([new Prop("justify-content", "flex-start")]);
                } else if (alignment instanceof Bottom) {
                  return toList([new Prop("justify-content", "flex-end")]);
                } else if (alignment instanceof Right) {
                  return toList([new Prop("align-items", "flex-end")]);
                } else if (alignment instanceof Left) {
                  return toList([new Prop("align-items", "flex-start")]);
                } else if (alignment instanceof CenterX) {
                  return toList([new Prop("align-items", "center")]);
                } else {
                  return toList([new Prop("justify-content", "center")]);
                }
              }
            )
          ])
        ),
        new Descriptor(
          dot(classes_page),
          toList([
            new Prop("display", "block"),
            new Child(
              dot(classes_any + ":first-child"),
              toList([new Prop("margin", "0 !important")])
            ),
            new Child(
              dot(
                classes_any + self_name(new Self(new Left())) + ":first-child + ." + classes_any
              ),
              toList([new Prop("margin", "0 !important")])
            ),
            new Child(
              dot(
                classes_any + self_name(new Self(new Right())) + ":first-child + ." + classes_any
              ),
              toList([new Prop("margin", "0 !important")])
            ),
            describe_alignment(
              (alignment) => {
                if (alignment instanceof Top) {
                  return [toList([]), toList([])];
                } else if (alignment instanceof Bottom) {
                  return [toList([]), toList([])];
                } else if (alignment instanceof Right) {
                  return [
                    toList([]),
                    toList([
                      new Prop("float", "right"),
                      new Descriptor(
                        "::after",
                        toList([
                          new Prop("content", '""'),
                          new Prop("display", "table"),
                          new Prop("clear", "both")
                        ])
                      )
                    ])
                  ];
                } else if (alignment instanceof Left) {
                  return [
                    toList([]),
                    toList([
                      new Prop("float", "left"),
                      new Descriptor(
                        "::after",
                        toList([
                          new Prop("content", '""'),
                          new Prop("display", "table"),
                          new Prop("clear", "both")
                        ])
                      )
                    ])
                  ];
                } else if (alignment instanceof CenterX) {
                  return [toList([]), toList([])];
                } else {
                  return [toList([]), toList([])];
                }
              }
            )
          ])
        ),
        new Descriptor(
          dot(classes_input_multiline),
          toList([
            new Prop("white-space", "pre-wrap !important"),
            new Prop("height", "100%"),
            new Prop("width", "100%"),
            new Prop("background-color", "transparent")
          ])
        ),
        new Descriptor(
          dot(classes_input_multiline_wrapper),
          toList([
            new Descriptor(
              dot(classes_single),
              toList([new Prop("flex-basis", "auto")])
            )
          ])
        ),
        new Descriptor(
          dot(classes_input_multiline_parent),
          toList([
            new Prop("white-space", "pre-wrap !important"),
            new Prop("cursor", "text"),
            new Child(
              dot(classes_input_multiline_filler),
              toList([
                new Prop("white-space", "pre-wrap !important"),
                new Prop("color", "transparent")
              ])
            )
          ])
        ),
        new Descriptor(
          dot(classes_paragraph),
          toList([
            new Prop("display", "block"),
            new Prop("white-space", "normal"),
            new Prop("overflow-wrap", "break-word"),
            new Descriptor(
              dot(classes_has_behind),
              toList([
                new Prop("z-index", "0"),
                new Child(
                  dot(classes_behind),
                  toList([new Prop("z-index", "-1")])
                )
              ])
            ),
            new AllChildren(
              dot(classes_text),
              toList([
                new Prop("display", "inline"),
                new Prop("white-space", "normal")
              ])
            ),
            new AllChildren(
              dot(classes_paragraph),
              toList([
                new Prop("display", "inline"),
                new Descriptor("::after", toList([new Prop("content", "none")])),
                new Descriptor(
                  "::before",
                  toList([new Prop("content", "none")])
                )
              ])
            ),
            new AllChildren(
              dot(classes_single),
              toList([
                new Prop("display", "inline"),
                new Prop("white-space", "normal"),
                new Descriptor(
                  dot(classes_width_exact),
                  toList([new Prop("display", "inline-block")])
                ),
                new Descriptor(
                  dot(classes_in_front),
                  toList([new Prop("display", "flex")])
                ),
                new Descriptor(
                  dot(classes_behind),
                  toList([new Prop("display", "flex")])
                ),
                new Descriptor(
                  dot(classes_above),
                  toList([new Prop("display", "flex")])
                ),
                new Descriptor(
                  dot(classes_below),
                  toList([new Prop("display", "flex")])
                ),
                new Descriptor(
                  dot(classes_on_right),
                  toList([new Prop("display", "flex")])
                ),
                new Descriptor(
                  dot(classes_on_left),
                  toList([new Prop("display", "flex")])
                ),
                new Child(
                  dot(classes_text),
                  toList([
                    new Prop("display", "inline"),
                    new Prop("white-space", "normal")
                  ])
                )
              ])
            ),
            new Child(dot(classes_row), toList([new Prop("display", "inline")])),
            new Child(
              dot(classes_column),
              toList([new Prop("display", "inline-flex")])
            ),
            new Child(
              dot(classes_grid),
              toList([new Prop("display", "inline-grid")])
            ),
            describe_alignment(
              (alignment) => {
                if (alignment instanceof Top) {
                  return [toList([]), toList([])];
                } else if (alignment instanceof Bottom) {
                  return [toList([]), toList([])];
                } else if (alignment instanceof Right) {
                  return [toList([]), toList([new Prop("float", "right")])];
                } else if (alignment instanceof Left) {
                  return [toList([]), toList([new Prop("float", "left")])];
                } else if (alignment instanceof CenterX) {
                  return [toList([]), toList([])];
                } else {
                  return [toList([]), toList([])];
                }
              }
            )
          ])
        ),
        new Descriptor(".hidden", toList([new Prop("display", "none")])),
        new Descriptor(
          dot(classes_text_thin),
          toList([new Prop("font-weight", "100")])
        ),
        new Descriptor(
          dot(classes_text_extra_light),
          toList([new Prop("font-weight", "200")])
        ),
        new Descriptor(
          dot(classes_text_light),
          toList([new Prop("font-weight", "300")])
        ),
        new Descriptor(
          dot(classes_text_normal_weight),
          toList([new Prop("font-weight", "400")])
        ),
        new Descriptor(
          dot(classes_text_medium),
          toList([new Prop("font-weight", "500")])
        ),
        new Descriptor(
          dot(classes_text_semi_bold),
          toList([new Prop("font-weight", "600")])
        ),
        new Descriptor(
          dot(classes_bold),
          toList([new Prop("font-weight", "700")])
        ),
        new Descriptor(
          dot(classes_text_extra_bold),
          toList([new Prop("font-weight", "800")])
        ),
        new Descriptor(
          dot(classes_text_heavy),
          toList([new Prop("font-weight", "900")])
        ),
        new Descriptor(
          dot(classes_italic),
          toList([new Prop("font-style", "italic")])
        ),
        new Descriptor(
          dot(classes_strike),
          toList([new Prop("text-decoration", "line-through")])
        ),
        new Descriptor(
          dot(classes_underline),
          toList([
            new Prop("text-decoration", "underline"),
            new Prop("text-decoration-skip-ink", "auto"),
            new Prop("text-decoration-skip", "ink")
          ])
        ),
        new Descriptor(
          dot(classes_underline + classes_strike),
          toList([
            new Prop("text-decoration", "line-through underline"),
            new Prop("text-decoration-skip-ink", "auto"),
            new Prop("text-decoration-skip", "ink")
          ])
        ),
        new Descriptor(
          dot(classes_text_unitalicized),
          toList([new Prop("font-style", "normal")])
        ),
        new Descriptor(
          dot(classes_text_justify),
          toList([new Prop("text-align", "justify")])
        ),
        new Descriptor(
          dot(classes_text_justify_all),
          toList([new Prop("text-align", "justify-all")])
        ),
        new Descriptor(
          dot(classes_text_center),
          toList([new Prop("text-align", "center")])
        ),
        new Descriptor(
          dot(classes_text_right),
          toList([new Prop("text-align", "right")])
        ),
        new Descriptor(
          dot(classes_text_left),
          toList([new Prop("text-align", "left")])
        ),
        new Descriptor(
          ".modal",
          toList([
            new Prop("position", "fixed"),
            new Prop("left", "0"),
            new Prop("top", "0"),
            new Prop("width", "100%"),
            new Prop("height", "100%"),
            new Prop("pointer-events", "none")
          ])
        )
      ])
    )
  ]);
}
var slider_reset = "\ninput[type=range] {\n  -webkit-appearance: none;\n  background: transparent;\n  position:absolute;\n  left:0;\n  top:0;\n  z-index:10;\n  width: 100%;\n  outline: dashed 1px;\n  height: 100%;\n  opacity: 0;\n}\n";
var track_reset = "\ninput[type=range]::-moz-range-track {\n    background: transparent;\n    cursor: pointer;\n}\ninput[type=range]::-ms-track {\n    background: transparent;\n    cursor: pointer;\n}\ninput[type=range]::-webkit-slider-runnable-track {\n    background: transparent;\n    cursor: pointer;\n}\n";
var thumb_reset = "\ninput[type=range]::-webkit-slider-thumb {\n    -webkit-appearance: none;\n    opacity: 0.5;\n    width: 80px;\n    height: 80px;\n    background-color: black;\n    border:none;\n    border-radius: 5px;\n}\ninput[type=range]::-moz-range-thumb {\n    opacity: 0.5;\n    width: 80px;\n    height: 80px;\n    background-color: black;\n    border:none;\n    border-radius: 5px;\n}\ninput[type=range]::-ms-thumb {\n    opacity: 0.5;\n    width: 80px;\n    height: 80px;\n    background-color: black;\n    border:none;\n    border-radius: 5px;\n}\ninput[type=range][orient=vertical]{\n    writing-mode: bt-lr; /* IE */\n    -webkit-appearance: slider-vertical;  /* WebKit */\n}\n";
function overrides() {
  return "\n@media screen and (-ms-high-contrast: active), (-ms-high-contrast: none) {" + dot(
    classes_any
  ) + dot(classes_row) + " > " + dot(classes_any) + " { flex-basis: auto !important; } " + dot(
    classes_any
  ) + dot(classes_row) + " > " + dot(classes_any) + dot(classes_container) + " { flex-basis: auto !important; }}" + input_text_reset() + slider_reset + track_reset + thumb_reset + explainer();
}
function rules() {
  return overrides() + render_compact(
    flatten(toList([base_sheet(), common_values()]))
  );
}

// build/dev/javascript/facet/facet/internal/model.mjs
var Unstyled = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Styled = class extends CustomType {
  constructor(styles, html) {
    super();
    this.styles = styles;
    this.html = html;
  }
};
var Text2 = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var NoStyleSheet = class extends CustomType {
};
var StaticRootAndDynamic = class extends CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
};
var OnlyDynamic = class extends CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
};
var AsRow = class extends CustomType {
};
var AsColumn = class extends CustomType {
};
var AsEl = class extends CustomType {
};
var AsGrid = class extends CustomType {
};
var AsParagraph = class extends CustomType {
};
var Left2 = class extends CustomType {
};
var CenterX2 = class extends CustomType {
};
var Right2 = class extends CustomType {
};
var Top2 = class extends CustomType {
};
var CenterY2 = class extends CustomType {
};
var Bottom2 = class extends CustomType {
};
var Style = class extends CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
};
var FontFamily = class extends CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
};
var FontSize = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Single = class extends CustomType {
  constructor(classname, prop, value2) {
    super();
    this.classname = classname;
    this.prop = prop;
    this.value = value2;
  }
};
var Colored = class extends CustomType {
  constructor($0, $1, $2) {
    super();
    this[0] = $0;
    this[1] = $1;
    this[2] = $2;
  }
};
var SpacingStyle = class extends CustomType {
  constructor($0, $1, $2) {
    super();
    this[0] = $0;
    this[1] = $1;
    this[2] = $2;
  }
};
var BorderWidth = class extends CustomType {
  constructor($0, $1, $2, $3, $4) {
    super();
    this[0] = $0;
    this[1] = $1;
    this[2] = $2;
    this[3] = $3;
    this[4] = $4;
  }
};
var PaddingStyle = class extends CustomType {
  constructor($0, $1, $2, $3, $4) {
    super();
    this[0] = $0;
    this[1] = $1;
    this[2] = $2;
    this[3] = $3;
    this[4] = $4;
  }
};
var GridTemplateStyle = class extends CustomType {
  constructor(spacing3, columns, rows) {
    super();
    this.spacing = spacing3;
    this.columns = columns;
    this.rows = rows;
  }
};
var GridPosition = class extends CustomType {
  constructor(row2, col, width4, height3) {
    super();
    this.row = row2;
    this.col = col;
    this.width = width4;
    this.height = height3;
  }
};
var Transform = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var PseudoSelector = class extends CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
};
var Transparency = class extends CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
};
var Untransformed = class extends CustomType {
};
var Moved = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var FullTransform = class extends CustomType {
  constructor($0, $1, $2, $3) {
    super();
    this[0] = $0;
    this[1] = $1;
    this[2] = $2;
    this[3] = $3;
  }
};
var Focus = class extends CustomType {
};
var Hover = class extends CustomType {
};
var Serif = class extends CustomType {
};
var SansSerif = class extends CustomType {
};
var Monospace = class extends CustomType {
};
var Typeface = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var ImportFont = class extends CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
};
var FontWith = class extends CustomType {
  constructor(name, adjustment, variants) {
    super();
    this.name = name;
    this.adjustment = adjustment;
    this.variants = variants;
  }
};
var VariantActive = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var VariantOff = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Property2 = class extends CustomType {
  constructor(key2, val) {
    super();
    this.key = key2;
    this.val = val;
  }
};
var NoAttribute = class extends CustomType {
};
var Attr = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Describe = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Class2 = class extends CustomType {
  constructor(invalidation_key, name) {
    super();
    this.invalidation_key = invalidation_key;
    this.name = name;
  }
};
var StyleClass = class extends CustomType {
  constructor(invalidation_key, style2) {
    super();
    this.invalidation_key = invalidation_key;
    this.style = style2;
  }
};
var AlignY = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var AlignX = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Width = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Height = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Nearby = class extends CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
};
var MoveX = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var MoveY = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var MoveZ = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var MoveXYZ = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Rotate = class extends CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
};
var Main = class extends CustomType {
};
var Navigation = class extends CustomType {
};
var ContentInfo = class extends CustomType {
};
var Complementary = class extends CustomType {
};
var Heading = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Label = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var LivePolite = class extends CustomType {
};
var LiveAssertive = class extends CustomType {
};
var Button = class extends CustomType {
};
var Px = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Content2 = class extends CustomType {
};
var Fill = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Min = class extends CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
};
var Above2 = class extends CustomType {
};
var Below2 = class extends CustomType {
};
var OnRight2 = class extends CustomType {
};
var OnLeft2 = class extends CustomType {
};
var InFront = class extends CustomType {
};
var Behind2 = class extends CustomType {
};
var Rgba = class extends CustomType {
  constructor($0, $1, $2, $3) {
    super();
    this[0] = $0;
    this[1] = $1;
    this[2] = $2;
    this[3] = $3;
  }
};
var Oklch = class extends CustomType {
  constructor($0, $1, $2) {
    super();
    this[0] = $0;
    this[1] = $1;
    this[2] = $2;
  }
};
var Generic = class extends CustomType {
};
var NodeName = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Embedded = class extends CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
};
var NoNearbyChildren = class extends CustomType {
};
var ChildrenBehind = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var ChildrenInFront = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var ChildrenBehindAndInFront = class extends CustomType {
  constructor(behind, infront) {
    super();
    this.behind = behind;
    this.infront = infront;
  }
};
var Gathered = class extends CustomType {
  constructor(node, attributes, styles, children, has) {
    super();
    this.node = node;
    this.attributes = attributes;
    this.styles = styles;
    this.children = children;
    this.has = has;
  }
};
var Unkeyed = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Keyed = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Layout = class extends CustomType {
};
var NoStaticStyleSheet = class extends CustomType {
};
var OptionRecord = class extends CustomType {
  constructor(hover2, focus2, mode) {
    super();
    this.hover = hover2;
    this.focus = focus2;
    this.mode = mode;
  }
};
var OptionRecordBuidler = class extends CustomType {
  constructor(hover2, focus2, mode) {
    super();
    this.hover = hover2;
    this.focus = focus2;
    this.mode = mode;
  }
};
var NoHover = class extends CustomType {
};
var AllowHover = class extends CustomType {
};
var HoverOption = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var FocusStyleOption = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var FocusStyle = class extends CustomType {
  constructor(border_color2, background_color, shadow) {
    super();
    this.border_color = border_color2;
    this.background_color = background_color;
    this.shadow = shadow;
  }
};
var Shadow = class extends CustomType {
  constructor(color3, offset, blur, size3) {
    super();
    this.color = color3;
    this.offset = offset;
    this.blur = blur;
    this.size = size3;
  }
};
var InsetShadow = class extends CustomType {
  constructor(color3, offset, blur, size3, inset) {
    super();
    this.color = color3;
    this.offset = offset;
    this.blur = blur;
    this.size = size3;
    this.inset = inset;
  }
};
var FontSizing = class extends CustomType {
  constructor(vertical, height3, size3) {
    super();
    this.vertical = vertical;
    this.height = height3;
    this.size = size3;
  }
};
var ConvertedAdjustment = class extends CustomType {
  constructor(full, capital) {
    super();
    this.full = full;
    this.capital = capital;
  }
};
function render_variant(var$) {
  if (var$ instanceof VariantActive) {
    let name = var$[0];
    return '"' + name + '"';
  } else if (var$ instanceof VariantOff) {
    let name = var$[0];
    return '"' + name + '" 0';
  } else {
    let name = var$[0];
    let index4 = var$[1];
    return '"' + name + '" ' + to_string(index4);
  }
}
function render_variants(typeface) {
  if (typeface instanceof FontWith) {
    let variants = typeface.variants;
    let _pipe = variants;
    let _pipe$1 = map2(_pipe, render_variant);
    let _pipe$2 = join(_pipe$1, ", ");
    return new Some(_pipe$2);
  } else {
    return new None();
  }
}
function is_small_caps(var$) {
  if (var$ instanceof VariantActive) {
    let name = var$[0];
    return name === "smcp";
  } else if (var$ instanceof VariantOff) {
    return false;
  } else {
    let name = var$[0];
    let index4 = var$[1];
    return name === "smcp" && index4 === 1;
  }
}
function has_small_caps(typeface) {
  if (typeface instanceof FontWith) {
    let variants = typeface.variants;
    return any(variants, is_small_caps);
  } else {
    return false;
  }
}
function html_class(class_name) {
  return new Attr(class$(class_name));
}
function add_node_name(new_node, old) {
  if (old instanceof Generic) {
    return new NodeName(new_node);
  } else if (old instanceof NodeName) {
    let name = old[0];
    return new Embedded(name, new_node);
  } else {
    return old;
  }
}
function align_x_name(align) {
  if (align instanceof Left2) {
    return classes_aligned_horizontally + " " + classes_align_left;
  } else if (align instanceof CenterX2) {
    return classes_aligned_horizontally + " " + classes_align_center_x;
  } else {
    return classes_aligned_horizontally + " " + classes_align_right;
  }
}
function align_y_name(align) {
  if (align instanceof Top2) {
    return classes_aligned_vertically + " " + classes_align_top;
  } else if (align instanceof CenterY2) {
    return classes_aligned_vertically + " " + classes_align_center_y;
  } else {
    return classes_aligned_vertically + " " + classes_align_bottom;
  }
}
function transform_value(transform) {
  if (transform instanceof Untransformed) {
    return new None();
  } else if (transform instanceof Moved) {
    let x = transform[0][0];
    let y = transform[0][1];
    let z = transform[0][2];
    return new Some(
      "translate3d(" + float_to_string(x) + "px, " + float_to_string(y) + "px, " + float_to_string(
        z
      ) + "px)"
    );
  } else {
    let angle = transform[3];
    let ox = transform[2][0];
    let oy = transform[2][1];
    let oz = transform[2][2];
    let sx = transform[1][0];
    let sy = transform[1][1];
    let sz = transform[1][2];
    let tx = transform[0][0];
    let ty = transform[0][1];
    let tz = transform[0][2];
    let translate = "translate3d(" + float_to_string(tx) + "px, " + float_to_string(
      ty
    ) + "px, " + float_to_string(tz) + "px)";
    let scale2 = "scale3d(" + float_to_string(sx) + ", " + float_to_string(
      sy
    ) + ", " + float_to_string(sz) + ")";
    let rotate2 = "rotate3d(" + float_to_string(ox) + ", " + float_to_string(
      oy
    ) + ", " + float_to_string(oz) + ", " + float_to_string(angle) + "rad)";
    return new Some(translate + " " + scale2 + " " + rotate2);
  }
}
function compose_transformation(transform, component) {
  if (transform instanceof Untransformed) {
    if (component instanceof MoveX) {
      let x = component[0];
      return new Moved([x, 0, 0]);
    } else if (component instanceof MoveY) {
      let y = component[0];
      return new Moved([0, y, 0]);
    } else if (component instanceof MoveZ) {
      let z = component[0];
      return new Moved([0, 0, z]);
    } else if (component instanceof MoveXYZ) {
      let xyz = component[0];
      return new Moved(xyz);
    } else if (component instanceof Rotate) {
      let xyz = component[0];
      let angle = component[1];
      return new FullTransform([0, 0, 0], [1, 1, 1], xyz, angle);
    } else {
      let xyz = component[0];
      return new FullTransform([0, 0, 0], xyz, [0, 0, 1], 0);
    }
  } else if (transform instanceof Moved) {
    let moved = transform[0];
    let x = transform[0][0];
    let y = transform[0][1];
    let z = transform[0][2];
    if (component instanceof MoveX) {
      let new_x = component[0];
      return new Moved([new_x, y, z]);
    } else if (component instanceof MoveY) {
      let new_y = component[0];
      return new Moved([x, new_y, z]);
    } else if (component instanceof MoveZ) {
      let new_z = component[0];
      return new Moved([x, y, new_z]);
    } else if (component instanceof MoveXYZ) {
      let xyz = component[0];
      return new Moved(xyz);
    } else if (component instanceof Rotate) {
      let xyz = component[0];
      let angle = component[1];
      return new FullTransform(moved, [1, 1, 1], xyz, angle);
    } else {
      let scale2 = component[0];
      return new FullTransform(moved, scale2, [0, 0, 1], 0);
    }
  } else {
    let moved = transform[0];
    let scaled = transform[1];
    let origin = transform[2];
    let angle = transform[3];
    let x = transform[0][0];
    let y = transform[0][1];
    let z = transform[0][2];
    if (component instanceof MoveX) {
      let new_x = component[0];
      return new FullTransform([new_x, y, z], scaled, origin, angle);
    } else if (component instanceof MoveY) {
      let new_y = component[0];
      return new FullTransform([x, new_y, z], scaled, origin, angle);
    } else if (component instanceof MoveZ) {
      let new_z = component[0];
      return new FullTransform([x, y, new_z], scaled, origin, angle);
    } else if (component instanceof MoveXYZ) {
      let new_move = component[0];
      return new FullTransform(new_move, scaled, origin, angle);
    } else if (component instanceof Rotate) {
      let new_origin = component[0];
      let new_angle = component[1];
      return new FullTransform(moved, scaled, new_origin, new_angle);
    } else {
      let new_scale = component[0];
      return new FullTransform(moved, new_scale, origin, angle);
    }
  }
}
function skippable(flag2, style2) {
  let $ = isEqual(flag2, border_width());
  if ($) {
    if (style2 instanceof Single) {
      let val = style2.value;
      if (val === "0px") {
        return true;
      } else if (val === "1px") {
        return true;
      } else if (val === "2px") {
        return true;
      } else if (val === "3px") {
        return true;
      } else if (val === "4px") {
        return true;
      } else if (val === "5px") {
        return true;
      } else if (val === "6px") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    if (style2 instanceof FontSize) {
      let i = style2[0];
      return i >= 8 && i <= 32;
    } else if (style2 instanceof PaddingStyle) {
      let t = style2[1];
      let r = style2[2];
      let b = style2[3];
      let l = style2[4];
      return t === b && t === r && t === l && t >= 0 && t <= 24;
    } else {
      return false;
    }
  }
}
function render_width(w) {
  if (w instanceof Px) {
    let px2 = w[0];
    return [
      none3,
      classes_width_exact + " width-px-" + to_string(px2),
      toList([
        new Single(
          "width-px-" + to_string(px2),
          "width",
          to_string(px2) + "px"
        )
      ])
    ];
  } else if (w instanceof Content2) {
    return [
      add3(none3, width_content()),
      classes_width_content,
      toList([])
    ];
  } else if (w instanceof Fill) {
    let portion = w[0];
    let $ = portion === 1;
    if ($) {
      return [
        add3(none3, width_fill()),
        classes_width_fill,
        toList([])
      ];
    } else {
      return [
        add3(none3, width_fill()),
        classes_width_fill_portion + " width-fill-" + to_string(
          portion
        ),
        toList([
          new Single(
            classes_any + "." + classes_row + " > " + dot(
              "width-fill-" + to_string(portion)
            ),
            "flex-grow",
            to_string(portion * 1e5)
          )
        ])
      ];
    }
  } else if (w instanceof Min) {
    let min_size = w[0];
    let len = w[1];
    let cls = "min-width-" + to_string(min_size);
    let style_item = new Single(
      cls,
      "min-width",
      to_string(min_size) + "px"
    );
    let $ = render_width(len);
    let new_flag;
    let new_attrs;
    let new_styles;
    new_flag = $[0];
    new_attrs = $[1];
    new_styles = $[2];
    return [
      add3(new_flag, width_between()),
      cls + " " + new_attrs,
      prepend(style_item, new_styles)
    ];
  } else {
    let max_size = w[0];
    let len = w[1];
    let cls = "max-width-" + to_string(max_size);
    let style_item = new Single(
      cls,
      "max-width",
      to_string(max_size) + "px"
    );
    let $ = render_width(len);
    let new_flag;
    let new_attrs;
    let new_styles;
    new_flag = $[0];
    new_attrs = $[1];
    new_styles = $[2];
    return [
      add3(new_flag, width_between()),
      cls + " " + new_attrs,
      prepend(style_item, new_styles)
    ];
  }
}
function render_height(h) {
  if (h instanceof Px) {
    let px2 = h[0];
    let val = to_string(px2);
    let name = "height-px-" + val;
    return [
      none3,
      classes_height_exact + " " + name,
      toList([new Single(name, "height", val + "px")])
    ];
  } else if (h instanceof Content2) {
    return [
      add3(none3, height_content()),
      classes_height_content,
      toList([])
    ];
  } else if (h instanceof Fill) {
    let portion = h[0];
    let $ = portion === 1;
    if ($) {
      return [
        add3(none3, height_fill()),
        classes_height_fill,
        toList([])
      ];
    } else {
      return [
        add3(none3, height_fill()),
        classes_height_fill_portion + " height-fill-" + to_string(
          portion
        ),
        toList([
          new Single(
            classes_any + "." + classes_column + " > " + dot(
              "height-fill-" + to_string(portion)
            ),
            "flex-grow",
            to_string(portion * 1e5)
          )
        ])
      ];
    }
  } else if (h instanceof Min) {
    let min_size = h[0];
    let len = h[1];
    let cls = "min-height-" + to_string(min_size);
    let style_item = new Single(
      cls,
      "min-height",
      to_string(min_size) + "px !important"
    );
    let $ = render_height(len);
    let new_flag;
    let new_attrs;
    let new_styles;
    new_flag = $[0];
    new_attrs = $[1];
    new_styles = $[2];
    return [
      add3(new_flag, height_between()),
      cls + " " + new_attrs,
      prepend(style_item, new_styles)
    ];
  } else {
    let max_size = h[0];
    let len = h[1];
    let cls = "max-height-" + to_string(max_size);
    let style_item = new Single(
      cls,
      "max-height",
      to_string(max_size) + "px"
    );
    let $ = render_height(len);
    let new_flag;
    let new_attrs;
    let new_styles;
    new_flag = $[0];
    new_attrs = $[1];
    new_styles = $[2];
    return [
      add3(new_flag, height_between()),
      cls + " " + new_attrs,
      prepend(style_item, new_styles)
    ];
  }
}
function row_class() {
  return classes_any + " " + classes_row;
}
function column_class() {
  return classes_any + " " + classes_column;
}
function single_class() {
  return classes_any + " " + classes_single;
}
function grid_class() {
  return classes_any + " " + classes_grid;
}
function paragraph_class() {
  return classes_any + " " + classes_paragraph;
}
function page_class() {
  return classes_any + " " + classes_page;
}
function context_classes(context) {
  if (context instanceof AsRow) {
    return row_class();
  } else if (context instanceof AsColumn) {
    return column_class();
  } else if (context instanceof AsEl) {
    return single_class();
  } else if (context instanceof AsGrid) {
    return grid_class();
  } else if (context instanceof AsParagraph) {
    return paragraph_class();
  } else {
    return page_class();
  }
}
function add_children2(existing, nearby_children) {
  if (nearby_children instanceof NoNearbyChildren) {
    return existing;
  } else if (nearby_children instanceof ChildrenBehind) {
    let behind = nearby_children[0];
    return append(behind, existing);
  } else if (nearby_children instanceof ChildrenInFront) {
    let in_front = nearby_children[0];
    return append(existing, in_front);
  } else {
    let behind = nearby_children.behind;
    let in_front = nearby_children.infront;
    return flatten(toList([behind, existing, in_front]));
  }
}
function add_keyed_children(key2, existing, nearby_children) {
  let map_with_key = (elements) => {
    return map2(elements, (elem) => {
      return [key2, elem];
    });
  };
  if (nearby_children instanceof NoNearbyChildren) {
    return existing;
  } else if (nearby_children instanceof ChildrenBehind) {
    let behind = nearby_children[0];
    return append(map_with_key(behind), existing);
  } else if (nearby_children instanceof ChildrenInFront) {
    let in_front = nearby_children[0];
    return append(existing, map_with_key(in_front));
  } else {
    let behind = nearby_children.behind;
    let in_front = nearby_children.infront;
    return flatten(
      toList([map_with_key(behind), existing, map_with_key(in_front)])
    );
  }
}
function text_element_classes() {
  return classes_any + " " + classes_text + " " + classes_width_content + " " + classes_height_content;
}
function text_element(str) {
  return div(
    toList([class$(text_element_classes())]),
    toList([text3(str)])
  );
}
function nearby_element(location, elem) {
  let _block;
  if (location instanceof Above2) {
    _block = join(
      toList([
        classes_nearby,
        classes_single,
        classes_above
      ]),
      " "
    );
  } else if (location instanceof Below2) {
    _block = join(
      toList([
        classes_nearby,
        classes_single,
        classes_below
      ]),
      " "
    );
  } else if (location instanceof OnRight2) {
    _block = join(
      toList([
        classes_nearby,
        classes_single,
        classes_on_right
      ]),
      " "
    );
  } else if (location instanceof OnLeft2) {
    _block = join(
      toList([
        classes_nearby,
        classes_single,
        classes_on_left
      ]),
      " "
    );
  } else if (location instanceof InFront) {
    _block = join(
      toList([
        classes_nearby,
        classes_single,
        classes_in_front
      ]),
      " "
    );
  } else {
    _block = join(
      toList([
        classes_nearby,
        classes_single,
        classes_behind
      ]),
      " "
    );
  }
  let class_name = _block;
  let _block$1;
  if (elem instanceof Unstyled) {
    let inner_html = elem[0];
    _block$1 = inner_html(new AsEl());
  } else if (elem instanceof Styled) {
    let html = elem.html;
    _block$1 = html(new NoStyleSheet())(new AsEl());
  } else if (elem instanceof Text2) {
    let str = elem[0];
    _block$1 = text_element(str);
  } else {
    _block$1 = text3("");
  }
  let child = _block$1;
  return div(toList([class$(class_name)]), toList([child]));
}
function add_nearby_element(location, elem, existing) {
  let nearby = nearby_element(location, elem);
  if (existing instanceof NoNearbyChildren) {
    if (location instanceof Behind2) {
      return new ChildrenBehind(toList([nearby]));
    } else {
      return new ChildrenInFront(toList([nearby]));
    }
  } else if (existing instanceof ChildrenBehind) {
    let existing_behind = existing[0];
    if (location instanceof Behind2) {
      return new ChildrenBehind(prepend(nearby, existing_behind));
    } else {
      return new ChildrenBehindAndInFront(existing_behind, toList([nearby]));
    }
  } else if (existing instanceof ChildrenInFront) {
    let existing_in_front = existing[0];
    if (location instanceof Behind2) {
      return new ChildrenBehindAndInFront(toList([nearby]), existing_in_front);
    } else {
      return new ChildrenInFront(prepend(nearby, existing_in_front));
    }
  } else {
    let existing_behind = existing.behind;
    let existing_in_front = existing.infront;
    if (location instanceof Behind2) {
      return new ChildrenBehindAndInFront(
        prepend(nearby, existing_behind),
        existing_in_front
      );
    } else {
      return new ChildrenBehindAndInFront(
        existing_behind,
        prepend(nearby, existing_in_front)
      );
    }
  }
}
function text_element_fill_classes() {
  return classes_any + " " + classes_text + " " + classes_width_fill + " " + classes_height_fill;
}
function text_element_fill(str) {
  return div(
    toList([class$(text_element_fill_classes())]),
    toList([text3(str)])
  );
}
function to_html(el2, mode) {
  if (el2 instanceof Unstyled) {
    let html = el2[0];
    return html(new AsEl());
  } else if (el2 instanceof Styled) {
    let styles = el2.styles;
    let html = el2.html;
    return html(mode(styles))(new AsEl());
  } else if (el2 instanceof Text2) {
    let text5 = el2[0];
    return text_element(text5);
  } else {
    return text_element("");
  }
}
function render_font_class_name(current, font) {
  return current + (() => {
    if (font instanceof Serif) {
      return "serif";
    } else if (font instanceof SansSerif) {
      return "sans-serif";
    } else if (font instanceof Monospace) {
      return "monospace";
    } else if (font instanceof Typeface) {
      let name = font[0];
      let _pipe = name;
      let _pipe$1 = lowercase(_pipe);
      let _pipe$2 = split2(_pipe$1, " ");
      return join(_pipe$2, "-");
    } else if (font instanceof ImportFont) {
      let name = font[0];
      let _pipe = name;
      let _pipe$1 = lowercase(_pipe);
      let _pipe$2 = split2(_pipe$1, " ");
      return join(_pipe$2, "-");
    } else {
      let name = font.name;
      let _pipe = name;
      let _pipe$1 = lowercase(_pipe);
      let _pipe$2 = split2(_pipe$1, " ");
      return join(_pipe$2, "-");
    }
  })();
}
function bracket(selector, rules2) {
  let render_pair = (a) => {
    let name;
    let val;
    name = a[0];
    val = a[1];
    return name + ": " + val + ";";
  };
  return selector + " {" + join(map2(rules2, render_pair), "") + "}";
}
function render_null_adjustment_rule(font_to_adjust, other_font_name) {
  let _block;
  let $ = font_to_adjust === other_font_name;
  if ($) {
    _block = font_to_adjust;
  } else {
    _block = other_font_name + " ." + font_to_adjust;
  }
  let name = _block;
  let _pipe = toList([
    bracket(
      "." + name + "." + classes_size_by_capital + ", ." + name + " ." + classes_size_by_capital,
      toList([["line-height", "1"]])
    ),
    bracket(
      "." + name + "." + classes_size_by_capital + "> ." + classes_text + ", ." + name + " ." + classes_size_by_capital + " > ." + classes_text,
      toList([["vertical-align", "0"], ["line-height", "1"]])
    )
  ]);
  return join(_pipe, " ");
}
function font_rule(name, modifier, adjustments) {
  let parent_adj;
  let text_adjustment;
  parent_adj = adjustments[0];
  text_adjustment = adjustments[1];
  return toList([
    bracket(
      "." + name + "." + modifier + ", ." + name + " ." + modifier,
      parent_adj
    ),
    bracket(
      "." + name + "." + modifier + "> ." + classes_text + ", ." + name + " ." + modifier + " > ." + classes_text,
      text_adjustment
    )
  ]);
}
function render_font_adjustment_rule(font_to_adjust, full_and_capital, other_font_name) {
  let _block;
  let $ = font_to_adjust === other_font_name;
  if ($) {
    _block = font_to_adjust;
  } else {
    _block = other_font_name + " ." + font_to_adjust;
  }
  let name = _block;
  return join(
    append(
      font_rule(
        name,
        classes_size_by_capital,
        second(full_and_capital)
      ),
      font_rule(name, classes_full_size, first2(full_and_capital))
    ),
    " "
  );
}
function font_adjustment_rules(converted) {
  return [
    toList([["display", "block"]]),
    toList([
      ["display", "inline-block"],
      ["line-height", float_to_string(converted.height)],
      ["vertical-align", float_to_string(converted.vertical) + "em"],
      ["font-size", float_to_string(converted.size) + "em"]
    ])
  ];
}
function font_name(font) {
  if (font instanceof Serif) {
    return "serif";
  } else if (font instanceof SansSerif) {
    return "sans-serif";
  } else if (font instanceof Monospace) {
    return "monospace";
  } else if (font instanceof Typeface) {
    let name = font[0];
    return '"' + name + '"';
  } else if (font instanceof ImportFont) {
    let name = font[0];
    return '"' + name + '"';
  } else {
    let name = font.name;
    return '"' + name + '"';
  }
}
function top_level_value(rule) {
  if (rule instanceof FontFamily) {
    let name = rule[0];
    let typefaces = rule[1];
    return new Some([name, typefaces]);
  } else {
    return new None();
  }
}
function render_props(force, p2, existing) {
  if (force) {
    return existing + "\n  " + p2.key + ": " + p2.val + " !important;";
  } else {
    return existing + "\n  " + p2.key + ": " + p2.val + ";";
  }
}
function render_style(options, maybe_pseudo, selector, props) {
  if (maybe_pseudo instanceof Some) {
    let pseudo = maybe_pseudo[0];
    if (pseudo instanceof Focus) {
      let rendered_props = fold(
        props,
        "",
        (acc, p2) => {
          return render_props(false, p2, acc);
        }
      );
      return toList([
        selector + "-fs:focus {" + rendered_props + "\n}",
        "." + classes_any + ":focus " + selector + "-fs {" + rendered_props + "\n}",
        selector + "-fs:focus-within {" + rendered_props + "\n}",
        ".ui-slide-bar:focus + " + dot(classes_any) + " .focusable-thumb" + selector + "-fs {" + rendered_props + "\n}"
      ]);
    } else if (pseudo instanceof Hover) {
      let $ = options.hover;
      if ($ instanceof NoHover) {
        return toList([]);
      } else if ($ instanceof AllowHover) {
        return toList([
          selector + "-hv:hover {" + fold(
            props,
            "",
            (acc, p2) => {
              return render_props(false, p2, acc);
            }
          ) + "\n}"
        ]);
      } else {
        return toList([
          selector + "-hv {" + fold(
            props,
            "",
            (acc, p2) => {
              return render_props(true, p2, acc);
            }
          ) + "\n}"
        ]);
      }
    } else {
      return toList([
        selector + "-act:active {" + fold(
          props,
          "",
          (acc, p2) => {
            return render_props(false, p2, acc);
          }
        ) + "\n}"
      ]);
    }
  } else {
    return toList([
      selector + "{" + fold(
        props,
        "",
        (acc, p2) => {
          return render_props(false, p2, acc);
        }
      ) + "\n}"
    ]);
  }
}
function to_grid_length_helper(loop$minimum, loop$maximum, loop$x) {
  while (true) {
    let minimum = loop$minimum;
    let maximum = loop$maximum;
    let x = loop$x;
    if (x instanceof Px) {
      let px2 = x[0];
      return to_string(px2) + "px";
    } else if (x instanceof Content2) {
      if (maximum instanceof Some) {
        if (minimum instanceof Some) {
          let max_size = maximum[0];
          let min_size = minimum[0];
          return "minmax(" + to_string(min_size) + "px, " + to_string(
            max_size
          ) + "px)";
        } else {
          let max_size = maximum[0];
          return "minmax(max-content, " + to_string(max_size) + "px)";
        }
      } else if (minimum instanceof Some) {
        let min_size = minimum[0];
        return "minmax(" + to_string(min_size) + "px, max-content)";
      } else {
        return "max-content";
      }
    } else if (x instanceof Fill) {
      let i = x[0];
      if (maximum instanceof Some) {
        if (minimum instanceof Some) {
          let max_size = maximum[0];
          let min_size = minimum[0];
          return "minmax(" + to_string(min_size) + "px, " + to_string(
            max_size
          ) + "px)";
        } else {
          let max_size = maximum[0];
          return "minmax(max-content, " + to_string(max_size) + "px)";
        }
      } else if (minimum instanceof Some) {
        let min_size = minimum[0];
        return "minmax(" + to_string(min_size) + "px, " + to_string(
          i
        ) + "frfr)";
      } else {
        return to_string(i) + "fr";
      }
    } else if (x instanceof Min) {
      let m = x[0];
      let len = x[1];
      loop$minimum = new Some(m);
      loop$maximum = maximum;
      loop$x = len;
    } else {
      let m = x[0];
      let len = x[1];
      loop$minimum = minimum;
      loop$maximum = new Some(m);
      loop$x = len;
    }
  }
}
function length_class_name(len) {
  if (len instanceof Px) {
    let px2 = len[0];
    return to_string(px2) + "px";
  } else if (len instanceof Content2) {
    return "auto";
  } else if (len instanceof Fill) {
    let i = len[0];
    return to_string(i) + "fr";
  } else if (len instanceof Min) {
    let min3 = len[0];
    let l = len[1];
    return "min" + to_string(min3) + length_class_name(l);
  } else {
    let max4 = len[0];
    let l = len[1];
    return "max" + to_string(max4) + length_class_name(l);
  }
}
function float_class(x) {
  return to_string(round(x * 255));
}
function transform_class(transform) {
  if (transform instanceof Untransformed) {
    return new None();
  } else if (transform instanceof Moved) {
    let x = transform[0][0];
    let y = transform[0][1];
    let z = transform[0][2];
    return new Some(
      "mv-" + float_class(x) + "-" + float_class(y) + "-" + float_class(
        z
      )
    );
  } else {
    let angle = transform[3];
    let ox = transform[2][0];
    let oy = transform[2][1];
    let oz = transform[2][2];
    let sx = transform[1][0];
    let sy = transform[1][1];
    let sz = transform[1][2];
    let tx = transform[0][0];
    let ty = transform[0][1];
    let tz = transform[0][2];
    return new Some(
      "tfrm-" + float_class(tx) + "-" + float_class(ty) + "-" + float_class(
        tz
      ) + "-" + float_class(sx) + "-" + float_class(sy) + "-" + float_class(
        sz
      ) + "-" + float_class(ox) + "-" + float_class(oy) + "-" + float_class(
        oz
      ) + "-" + float_class(angle)
    );
  }
}
function format_color(color3) {
  if (color3 instanceof Rgba) {
    let red = color3[0];
    let green = color3[1];
    let blue = color3[2];
    let alpha = color3[3];
    let r = to_string(round(red * 255));
    let g = to_string(round(green * 255));
    let b = to_string(round(blue * 255));
    let a = float_to_string(alpha);
    return "rgba(" + r + "," + g + "," + b + "," + a + ")";
  } else {
    let a = color3[0];
    let b = color3[1];
    let c = color3[2];
    return "oklch(" + float_to_string(a) + " " + float_to_string(b) + " " + float_to_string(
      c
    ) + ")";
  }
}
function render_style_rule(options, rule, maybe_pseudo) {
  if (rule instanceof Style) {
    let selector = rule[0];
    let props = rule[1];
    return render_style(options, maybe_pseudo, selector, props);
  } else if (rule instanceof FontFamily) {
    let name = rule[0];
    let typefaces = rule[1];
    let _block;
    let _pipe = typefaces;
    let _pipe$1 = map2(_pipe, render_variants);
    let _pipe$2 = values(_pipe$1);
    _block = join(_pipe$2, ", ");
    let features = _block;
    let families = toList([
      new Property2(
        "font-family",
        (() => {
          let _pipe$3 = typefaces;
          let _pipe$4 = map2(_pipe$3, font_name);
          return join(_pipe$4, ", ");
        })()
      ),
      new Property2("font-feature-settings", features),
      new Property2(
        "font-variant",
        (() => {
          let $ = any(typefaces, has_small_caps);
          if ($) {
            return "small-caps";
          } else {
            return "normal";
          }
        })()
      )
    ]);
    return render_style(options, maybe_pseudo, "." + name, families);
  } else if (rule instanceof FontSize) {
    let i = rule[0];
    return render_style(
      options,
      maybe_pseudo,
      ".font-size-" + to_string(i),
      toList([new Property2("font-size", to_string(i) + "px")])
    );
  } else if (rule instanceof Single) {
    let class$2 = rule.classname;
    let prop = rule.prop;
    let val = rule.value;
    return render_style(
      options,
      maybe_pseudo,
      "." + class$2,
      toList([new Property2(prop, val)])
    );
  } else if (rule instanceof Colored) {
    let class$2 = rule[0];
    let prop = rule[1];
    let color3 = rule[2];
    return render_style(
      options,
      maybe_pseudo,
      "." + class$2,
      toList([new Property2(prop, format_color(color3))])
    );
  } else if (rule instanceof SpacingStyle) {
    let cls = rule[0];
    let x = rule[1];
    let y = rule[2];
    let class$2 = "." + cls;
    let half_x = float_to_string(identity(x) / 2) + "px";
    let half_y = float_to_string(identity(y) / 2) + "px";
    let x_px = to_string(x) + "px";
    let y_px = to_string(y) + "px";
    let row2 = "." + classes_row;
    let wrapped_row = "." + classes_wrapped + row2;
    let column2 = "." + classes_column;
    let page = "." + classes_page;
    let paragraph = "." + classes_paragraph;
    let left = "." + classes_align_left;
    let right = "." + classes_align_right;
    let any2 = "." + classes_any;
    let single2 = "." + classes_single;
    return flatten(
      toList([
        render_style(
          options,
          maybe_pseudo,
          class$2 + row2 + " > " + any2 + " + " + any2,
          toList([new Property2("margin-left", x_px)])
        ),
        render_style(
          options,
          maybe_pseudo,
          class$2 + wrapped_row + " > " + any2,
          toList([new Property2("margin", half_y + " " + half_x)])
        ),
        render_style(
          options,
          maybe_pseudo,
          class$2 + column2 + " > " + any2 + " + " + any2,
          toList([new Property2("margin-top", y_px)])
        ),
        render_style(
          options,
          maybe_pseudo,
          class$2 + page + " > " + any2 + " + " + any2,
          toList([new Property2("margin-top", y_px)])
        ),
        render_style(
          options,
          maybe_pseudo,
          class$2 + page + " > " + left,
          toList([new Property2("margin-right", x_px)])
        ),
        render_style(
          options,
          maybe_pseudo,
          class$2 + page + " > " + right,
          toList([new Property2("margin-left", x_px)])
        ),
        render_style(
          options,
          maybe_pseudo,
          class$2 + paragraph,
          toList([
            new Property2(
              "line-height",
              "calc(1em + " + to_string(y) + "px)"
            )
          ])
        ),
        render_style(
          options,
          maybe_pseudo,
          "textarea" + any2 + class$2,
          toList([
            new Property2(
              "line-height",
              "calc(1em + " + to_string(y) + "px)"
            ),
            new Property2("height", "calc(100% + " + to_string(y) + "px)")
          ])
        ),
        render_style(
          options,
          maybe_pseudo,
          class$2 + paragraph + " > " + left,
          toList([new Property2("margin-right", x_px)])
        ),
        render_style(
          options,
          maybe_pseudo,
          class$2 + paragraph + " > " + right,
          toList([new Property2("margin-left", x_px)])
        ),
        render_style(
          options,
          maybe_pseudo,
          class$2 + paragraph + "::after",
          toList([
            new Property2("content", "''"),
            new Property2("display", "block"),
            new Property2("height", "0"),
            new Property2("width", "0"),
            new Property2(
              "margin-top",
              to_string(-1 * globalThis.Math.trunc(y / 2)) + "px"
            )
          ])
        ),
        render_style(
          options,
          maybe_pseudo,
          class$2 + paragraph + "::before",
          toList([
            new Property2("content", "''"),
            new Property2("display", "block"),
            new Property2("height", "0"),
            new Property2("width", "0"),
            new Property2(
              "margin-bottom",
              to_string(-1 * globalThis.Math.trunc(y / 2)) + "px"
            )
          ])
        )
      ])
    );
  } else if (rule instanceof BorderWidth) {
    let cls = rule[0];
    let top = rule[1];
    let right = rule[2];
    let bottom = rule[3];
    let left = rule[4];
    let class$2 = "." + cls;
    return render_style(
      options,
      maybe_pseudo,
      class$2,
      toList([
        new Property2(
          "border-width",
          to_string(top) + "px " + to_string(right) + "px " + to_string(
            bottom
          ) + "px " + to_string(left) + "px"
        )
      ])
    );
  } else if (rule instanceof PaddingStyle) {
    let cls = rule[0];
    let top = rule[1];
    let right = rule[2];
    let bottom = rule[3];
    let left = rule[4];
    let class$2 = "." + cls;
    return render_style(
      options,
      maybe_pseudo,
      class$2,
      toList([
        new Property2(
          "padding",
          float_to_string(top) + "px " + float_to_string(right) + "px " + float_to_string(
            bottom
          ) + "px " + float_to_string(left) + "px"
        )
      ])
    );
  } else if (rule instanceof GridTemplateStyle) {
    let spacing3 = rule.spacing;
    let columns = rule.columns;
    let rows = rule.rows;
    let class$2 = ".grid-rows-" + join(
      map2(rows, length_class_name),
      "-"
    ) + "-cols-" + join(map2(columns, length_class_name), "-") + "-space-x-" + length_class_name(
      first2(spacing3)
    ) + "-space-y-" + length_class_name(second(spacing3));
    let to_grid_length = (x) => {
      return to_grid_length_helper(new None(), new None(), x);
    };
    let y_spacing = to_grid_length(second(spacing3));
    let _block;
    let _pipe = columns;
    let _pipe$1 = map2(_pipe, to_grid_length);
    let _pipe$2 = join(_pipe$1, y_spacing);
    _block = ((x) => {
      return "-ms-grid-columns: " + x + ";";
    })(_pipe$2);
    let ms_columns = _block;
    let _block$1;
    let _pipe$3 = columns;
    let _pipe$4 = map2(_pipe$3, to_grid_length);
    let _pipe$5 = join(_pipe$4, y_spacing);
    _block$1 = ((x) => {
      return "-ms-grid-rows: " + x + ";";
    })(_pipe$5);
    let ms_rows = _block$1;
    let base = class$2 + "{" + ms_columns + ms_rows + "}";
    let _block$2;
    let _pipe$6 = columns;
    let _pipe$7 = map2(_pipe$6, to_grid_length);
    let _pipe$8 = join(_pipe$7, " ");
    _block$2 = ((x) => {
      return "grid-template-columns: " + x + ";";
    })(
      _pipe$8
    );
    let columns$1 = _block$2;
    let _block$3;
    let _pipe$9 = rows;
    let _pipe$10 = map2(_pipe$9, to_grid_length);
    let _pipe$11 = join(_pipe$10, " ");
    _block$3 = ((x) => {
      return "grid-template-rows: " + x + ";";
    })(_pipe$11);
    let rows$1 = _block$3;
    let gap_x = "grid-column-gap:" + to_grid_length(first2(spacing3)) + ";";
    let gap_y = "grid-row-gap:" + to_grid_length(second(spacing3)) + ";";
    let modern_grid = class$2 + "{" + columns$1 + rows$1 + gap_x + gap_y + "}";
    let supports = "@supports (display:grid) {" + modern_grid + "}";
    return toList([base, supports]);
  } else if (rule instanceof GridPosition) {
    let row2 = rule.row;
    let col = rule.col;
    let width4 = rule.width;
    let height3 = rule.height;
    let class$2 = ".grid-pos-" + to_string(row2) + "-" + to_string(
      col
    ) + "-" + to_string(width4) + "-" + to_string(height3);
    let ms_position = join(
      toList([
        "-ms-grid-row: " + to_string(row2) + ";",
        "-ms-grid-row-span: " + to_string(height3) + ";",
        "-ms-grid-column: " + to_string(col) + ";",
        "-ms-grid-column-span: " + to_string(width4) + ";"
      ]),
      " "
    );
    let base = class$2 + "{" + ms_position + "}";
    let modern_position = join(
      toList([
        "grid-row: " + to_string(row2) + " / " + to_string(
          row2 + height3
        ) + ";",
        "grid-column: " + to_string(col) + " / " + to_string(
          col + width4
        ) + ";"
      ]),
      " "
    );
    let modern_grid = class$2 + "{" + modern_position + "}";
    let supports = "@supports (display:grid) {" + modern_grid + "}";
    return toList([base, supports]);
  } else if (rule instanceof Transform) {
    let transform = rule[0];
    let val_ = transform_value(transform);
    let class_ = transform_class(transform);
    if (val_ instanceof Some && class_ instanceof Some) {
      let v = val_[0];
      let cls = class_[0];
      return render_style(
        options,
        maybe_pseudo,
        "." + cls,
        toList([new Property2("transform", v)])
      );
    } else {
      return toList([]);
    }
  } else if (rule instanceof PseudoSelector) {
    let class$2 = rule[0];
    let styles = rule[1];
    let render_pseudo_rule = (style2) => {
      return render_style_rule(options, style2, new Some(class$2));
    };
    return flatten(map2(styles, render_pseudo_rule));
  } else if (rule instanceof Transparency) {
    let name = rule[0];
    let transparency2 = rule[1];
    let _block;
    let $ = 1 - transparency2 <= 1;
    if ($) {
      let $1 = 1 - transparency2 >= 0;
      if ($1) {
        _block = 1 - transparency2;
      } else {
        _block = 0;
      }
    } else {
      _block = 1;
    }
    let opacity = _block;
    return render_style(
      options,
      maybe_pseudo,
      "." + name,
      toList([new Property2("opacity", float_to_string(opacity))])
    );
  } else {
    let name = rule[0];
    let prop = rule[1];
    return render_style(
      options,
      maybe_pseudo,
      "." + name,
      toList([new Property2("box-shadow", prop)])
    );
  }
}
function format_box_shadow(shadow) {
  return join(
    values(
      toList([
        (() => {
          let $ = shadow.inset;
          if ($) {
            return new Some("inset");
          } else {
            return new None();
          }
        })(),
        new Some(float_to_string(first2(shadow.offset)) + "px"),
        new Some(float_to_string(second(shadow.offset)) + "px"),
        new Some(float_to_string(shadow.blur) + "px"),
        new Some(float_to_string(shadow.size) + "px"),
        new Some(format_color(shadow.color))
      ])
    ),
    " "
  );
}
function render_focus_style(focus2) {
  return toList([
    new Style(
      dot(classes_focused_within) + ":focus-within",
      values(
        toList([
          map(
            focus2.border_color,
            (color3) => {
              return new Property2("border-color", format_color(color3));
            }
          ),
          map(
            focus2.background_color,
            (color3) => {
              return new Property2("background-color", format_color(color3));
            }
          ),
          map(
            focus2.shadow,
            (shadow) => {
              return new Property2(
                "box-shadow",
                format_box_shadow(
                  new InsetShadow(
                    shadow.color,
                    [
                      identity(first2(shadow.offset)),
                      identity(second(shadow.offset))
                    ],
                    identity(shadow.blur),
                    identity(shadow.size),
                    false
                  )
                )
              );
            }
          ),
          new Some(new Property2("outline", "none"))
        ])
      )
    ),
    new Style(
      dot(classes_any) + ":focus .focusable, " + dot(
        classes_any
      ) + ".focusable:focus, .ui-slide-bar:focus + " + dot(
        classes_any
      ) + " .focusable-thumb",
      values(
        toList([
          map(
            focus2.border_color,
            (color3) => {
              return new Property2("border-color", format_color(color3));
            }
          ),
          map(
            focus2.background_color,
            (color3) => {
              return new Property2("background-color", format_color(color3));
            }
          ),
          map(
            focus2.shadow,
            (shadow) => {
              return new Property2(
                "box-shadow",
                format_box_shadow(
                  new InsetShadow(
                    shadow.color,
                    [
                      identity(first2(shadow.offset)),
                      identity(second(shadow.offset))
                    ],
                    identity(shadow.blur),
                    identity(shadow.size),
                    false
                  )
                )
              );
            }
          ),
          new Some(new Property2("outline", "none"))
        ])
      )
    )
  ]);
}
function format_color_class(color3) {
  if (color3 instanceof Rgba) {
    let red = color3[0];
    let green = color3[1];
    let blue = color3[2];
    let alpha = color3[3];
    return float_class(red) + "-" + float_class(green) + "-" + float_class(
      blue
    ) + "-" + float_class(alpha);
  } else {
    let a = color3[0];
    let b = color3[1];
    let c = color3[2];
    return "oklch-" + float_class(a) + "-" + float_class(b) + "-" + float_class(
      c
    );
  }
}
function root_style() {
  let families = toList([
    new Typeface("Open Sans"),
    new Typeface("Helvetica"),
    new Typeface("Verdana"),
    new SansSerif()
  ]);
  return toList([
    new StyleClass(
      bg_color(),
      new Colored(
        "bg-" + format_color_class(new Rgba(1, 1, 1, 0)),
        "background-color",
        new Rgba(1, 1, 1, 0)
      )
    ),
    new StyleClass(
      font_color(),
      new Colored(
        "fg-" + format_color_class(new Rgba(0, 0, 0, 1)),
        "color",
        new Rgba(0, 0, 0, 1)
      )
    ),
    new StyleClass(font_size(), new FontSize(20)),
    new StyleClass(
      font_family(),
      new FontFamily(
        fold(families, "font-", render_font_class_name),
        families
      )
    )
  ]);
}
function spacing_name(x, y) {
  return "spacing-" + to_string(x) + "-" + to_string(y);
}
function get_style_name(style2) {
  if (style2 instanceof Style) {
    let class$2 = style2[0];
    return class$2;
  } else if (style2 instanceof FontFamily) {
    let name = style2[0];
    return name;
  } else if (style2 instanceof FontSize) {
    let i = style2[0];
    return "font-size-" + to_string(i);
  } else if (style2 instanceof Single) {
    let class$2 = style2.classname;
    return class$2;
  } else if (style2 instanceof Colored) {
    let class$2 = style2[0];
    return class$2;
  } else if (style2 instanceof SpacingStyle) {
    let cls = style2[0];
    return cls;
  } else if (style2 instanceof BorderWidth) {
    let cls = style2[0];
    return cls;
  } else if (style2 instanceof PaddingStyle) {
    let cls = style2[0];
    return cls;
  } else if (style2 instanceof GridTemplateStyle) {
    let spacing3 = style2.spacing;
    let columns = style2.columns;
    let rows = style2.rows;
    return "grid-rows-" + join(
      map2(rows, length_class_name),
      "-"
    ) + "-cols-" + join(map2(columns, length_class_name), "-") + "-space-x-" + length_class_name(
      first2(spacing3)
    ) + "-space-y-" + length_class_name(second(spacing3));
  } else if (style2 instanceof GridPosition) {
    let row2 = style2.row;
    let col = style2.col;
    let width4 = style2.width;
    let height3 = style2.height;
    return "gp grid-pos-" + to_string(row2) + "-" + to_string(
      col
    ) + "-" + to_string(width4) + "-" + to_string(height3);
  } else if (style2 instanceof Transform) {
    let x = style2[0];
    let $ = transform_class(x);
    if ($ instanceof Some) {
      let cls = $[0];
      return cls;
    } else {
      return "";
    }
  } else if (style2 instanceof PseudoSelector) {
    let selector = style2[0];
    let sub_style = style2[1];
    let _block;
    if (selector instanceof Focus) {
      _block = "fs";
    } else if (selector instanceof Hover) {
      _block = "hv";
    } else {
      _block = "act";
    }
    let name = _block;
    let _pipe = sub_style;
    let _pipe$1 = map2(
      _pipe,
      (sty) => {
        let $ = get_style_name(sty);
        if ($ === "") {
          return $;
        } else {
          let style_name = $;
          return style_name + "-" + name;
        }
      }
    );
    return join(_pipe$1, " ");
  } else if (style2 instanceof Transparency) {
    let name = style2[0];
    return name;
  } else {
    let name = style2[0];
    return name;
  }
}
function reduce_styles(styles, style2) {
  let cache;
  let existing;
  cache = styles[0];
  existing = styles[1];
  let style_name = get_style_name(style2);
  let $ = contains(cache, style_name);
  if ($) {
    return [cache, existing];
  } else {
    return [insert2(cache, style_name), prepend(style2, existing)];
  }
}
function gather_attr_recursive(loop$classes, loop$node, loop$has, loop$transform, loop$styles, loop$attrs, loop$children, loop$element_attrs) {
  while (true) {
    let classes = loop$classes;
    let node = loop$node;
    let has = loop$has;
    let transform = loop$transform;
    let styles = loop$styles;
    let attrs = loop$attrs;
    let children = loop$children;
    let element_attrs = loop$element_attrs;
    if (element_attrs instanceof Empty) {
      let $ = transform_class(transform);
      if ($ instanceof Some) {
        let class_name = $[0];
        return new Gathered(
          node,
          prepend(class$(classes + " " + class_name), attrs),
          prepend(new Transform(transform), styles),
          children,
          has
        );
      } else {
        return new Gathered(
          node,
          prepend(class$(classes), attrs),
          styles,
          children,
          has
        );
      }
    } else {
      let attribute3 = element_attrs.head;
      let remaining = element_attrs.tail;
      if (attribute3 instanceof NoAttribute) {
        loop$classes = classes;
        loop$node = node;
        loop$has = has;
        loop$transform = transform;
        loop$styles = styles;
        loop$attrs = attrs;
        loop$children = children;
        loop$element_attrs = remaining;
      } else if (attribute3 instanceof Attr) {
        let actual_attribute = attribute3[0];
        loop$classes = classes;
        loop$node = node;
        loop$has = has;
        loop$transform = transform;
        loop$styles = styles;
        loop$attrs = prepend(actual_attribute, attrs);
        loop$children = children;
        loop$element_attrs = remaining;
      } else if (attribute3 instanceof Describe) {
        let description = attribute3[0];
        if (description instanceof Main) {
          loop$classes = classes;
          loop$node = add_node_name("main", node);
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        } else if (description instanceof Navigation) {
          loop$classes = classes;
          loop$node = add_node_name("nav", node);
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        } else if (description instanceof ContentInfo) {
          loop$classes = classes;
          loop$node = add_node_name("footer", node);
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        } else if (description instanceof Complementary) {
          loop$classes = classes;
          loop$node = add_node_name("aside", node);
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        } else if (description instanceof Heading) {
          let i = description[0];
          if (i <= 1) {
            loop$classes = classes;
            loop$node = add_node_name("h1", node);
            loop$has = has;
            loop$transform = transform;
            loop$styles = styles;
            loop$attrs = attrs;
            loop$children = children;
            loop$element_attrs = remaining;
          } else if (i < 7) {
            loop$classes = classes;
            loop$node = add_node_name("h" + to_string(i), node);
            loop$has = has;
            loop$transform = transform;
            loop$styles = styles;
            loop$attrs = attrs;
            loop$children = children;
            loop$element_attrs = remaining;
          } else {
            loop$classes = classes;
            loop$node = add_node_name("h6", node);
            loop$has = has;
            loop$transform = transform;
            loop$styles = styles;
            loop$attrs = attrs;
            loop$children = children;
            loop$element_attrs = remaining;
          }
        } else if (description instanceof Label) {
          let label = description[0];
          loop$classes = classes;
          loop$node = node;
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = prepend(aria_label(label), attrs);
          loop$children = children;
          loop$element_attrs = remaining;
        } else if (description instanceof LivePolite) {
          loop$classes = classes;
          loop$node = node;
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = prepend(aria_live("polite"), attrs);
          loop$children = children;
          loop$element_attrs = remaining;
        } else if (description instanceof LiveAssertive) {
          loop$classes = classes;
          loop$node = node;
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = prepend(aria_live("assertive"), attrs);
          loop$children = children;
          loop$element_attrs = remaining;
        } else if (description instanceof Button) {
          loop$classes = classes;
          loop$node = node;
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = prepend(role("button"), attrs);
          loop$children = children;
          loop$element_attrs = remaining;
        } else {
          loop$classes = classes;
          loop$node = node;
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        }
      } else if (attribute3 instanceof Class2) {
        let flag2 = attribute3.invalidation_key;
        let exact_class_name = attribute3.name;
        let $ = present(flag2, has);
        if ($) {
          loop$classes = classes;
          loop$node = node;
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        } else {
          loop$classes = exact_class_name + " " + classes;
          loop$node = node;
          loop$has = add3(has, flag2);
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        }
      } else if (attribute3 instanceof StyleClass) {
        let flag2 = attribute3.invalidation_key;
        let style2 = attribute3.style;
        let $ = present(flag2, has);
        if ($) {
          loop$classes = classes;
          loop$node = node;
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        } else {
          let $1 = skippable(flag2, style2);
          if ($1) {
            loop$classes = get_style_name(style2) + " " + classes;
            loop$node = node;
            loop$has = add3(has, flag2);
            loop$transform = transform;
            loop$styles = styles;
            loop$attrs = attrs;
            loop$children = children;
            loop$element_attrs = remaining;
          } else {
            loop$classes = get_style_name(style2) + " " + classes;
            loop$node = node;
            loop$has = add3(has, flag2);
            loop$transform = transform;
            loop$styles = prepend(style2, styles);
            loop$attrs = attrs;
            loop$children = children;
            loop$element_attrs = remaining;
          }
        }
      } else if (attribute3 instanceof AlignY) {
        let y = attribute3[0];
        let $ = present(y_align(), has);
        if ($) {
          loop$classes = classes;
          loop$node = node;
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        } else {
          let _block;
          let _pipe = add3(has, y_align());
          _block = ((flags) => {
            if (y instanceof CenterY2) {
              return add3(flags, center_y());
            } else if (y instanceof Bottom2) {
              return add3(flags, align_bottom());
            } else {
              return flags;
            }
          })(_pipe);
          let new_flags = _block;
          loop$classes = align_y_name(y) + " " + classes;
          loop$node = node;
          loop$has = new_flags;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        }
      } else if (attribute3 instanceof AlignX) {
        let x = attribute3[0];
        let $ = present(x_align(), has);
        if ($) {
          loop$classes = classes;
          loop$node = node;
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        } else {
          let _block;
          let _pipe = has;
          let _pipe$1 = add3(_pipe, x_align());
          _block = ((flags) => {
            if (x instanceof CenterX2) {
              return add3(flags, center_x());
            } else if (x instanceof Right2) {
              return add3(flags, align_right());
            } else {
              return flags;
            }
          })(_pipe$1);
          let new_flags = _block;
          loop$classes = align_x_name(x) + " " + classes;
          loop$node = node;
          loop$has = new_flags;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        }
      } else if (attribute3 instanceof Width) {
        let width4 = attribute3[0];
        let $ = present(width(), has);
        if ($) {
          loop$classes = classes;
          loop$node = node;
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        } else {
          if (width4 instanceof Px) {
            let px2 = width4[0];
            let class_name = classes_width_exact + " width-px-" + to_string(
              px2
            );
            let style_item = new Single(
              "width-px-" + to_string(px2),
              "width",
              to_string(px2) + "px"
            );
            loop$classes = class_name + " " + classes;
            loop$node = node;
            loop$has = add3(has, width());
            loop$transform = transform;
            loop$styles = prepend(style_item, styles);
            loop$attrs = attrs;
            loop$children = children;
            loop$element_attrs = remaining;
          } else if (width4 instanceof Content2) {
            loop$classes = classes + " " + classes_width_content;
            loop$node = node;
            loop$has = (() => {
              let _pipe = has;
              let _pipe$1 = add3(_pipe, width_content());
              return add3(_pipe$1, width());
            })();
            loop$transform = transform;
            loop$styles = styles;
            loop$attrs = attrs;
            loop$children = children;
            loop$element_attrs = remaining;
          } else if (width4 instanceof Fill) {
            let portion = width4[0];
            let $1 = portion === 1;
            if ($1) {
              loop$classes = classes + " " + classes_width_fill;
              loop$node = node;
              loop$has = (() => {
                let _pipe = has;
                let _pipe$1 = add3(_pipe, width_fill());
                return add3(_pipe$1, width());
              })();
              loop$transform = transform;
              loop$styles = styles;
              loop$attrs = attrs;
              loop$children = children;
              loop$element_attrs = remaining;
            } else {
              loop$classes = classes + " " + classes_width_fill_portion + " width-fill-" + to_string(
                portion
              );
              loop$node = node;
              loop$has = (() => {
                let _pipe = has;
                let _pipe$1 = add3(_pipe, width_fill());
                return add3(_pipe$1, width());
              })();
              loop$transform = transform;
              loop$styles = prepend(
                new Single(
                  classes_any + "." + classes_row + " > " + dot(
                    "width-fill-" + to_string(portion)
                  ),
                  "flex-grow",
                  to_string(portion * 1e5)
                ),
                styles
              );
              loop$attrs = attrs;
              loop$children = children;
              loop$element_attrs = remaining;
            }
          } else {
            let $1 = render_width(width4);
            let add_to_flags;
            let new_class;
            let new_styles;
            add_to_flags = $1[0];
            new_class = $1[1];
            new_styles = $1[2];
            loop$classes = classes + " " + new_class;
            loop$node = node;
            loop$has = merge2(add_to_flags, add3(has, width()));
            loop$transform = transform;
            loop$styles = append(new_styles, styles);
            loop$attrs = attrs;
            loop$children = children;
            loop$element_attrs = remaining;
          }
        }
      } else if (attribute3 instanceof Height) {
        let height3 = attribute3[0];
        let $ = present(height(), has);
        if ($) {
          loop$classes = classes;
          loop$node = node;
          loop$has = has;
          loop$transform = transform;
          loop$styles = styles;
          loop$attrs = attrs;
          loop$children = children;
          loop$element_attrs = remaining;
        } else {
          if (height3 instanceof Px) {
            let px2 = height3[0];
            let val = to_string(px2) + "px";
            let name = "height-px-" + val;
            let style_item = new Single(name, "height", val);
            loop$classes = classes_height_exact + " " + name + " " + classes;
            loop$node = node;
            loop$has = add3(has, height());
            loop$transform = transform;
            loop$styles = prepend(style_item, styles);
            loop$attrs = attrs;
            loop$children = children;
            loop$element_attrs = remaining;
          } else if (height3 instanceof Content2) {
            loop$classes = classes_height_content + " " + classes;
            loop$node = node;
            loop$has = (() => {
              let _pipe = has;
              let _pipe$1 = add3(_pipe, height_content());
              return add3(_pipe$1, height());
            })();
            loop$transform = transform;
            loop$styles = styles;
            loop$attrs = attrs;
            loop$children = children;
            loop$element_attrs = remaining;
          } else if (height3 instanceof Fill) {
            let portion = height3[0];
            let $1 = portion === 1;
            if ($1) {
              loop$classes = echo(
                classes_height_fill + " " + classes,
                void 0,
                "src/facet/internal/model.gleam",
                1065
              );
              loop$node = node;
              loop$has = (() => {
                let _pipe = has;
                let _pipe$1 = add3(_pipe, height_fill());
                return add3(_pipe$1, height());
              })();
              loop$transform = transform;
              loop$styles = styles;
              loop$attrs = attrs;
              loop$children = children;
              loop$element_attrs = remaining;
            } else {
              loop$classes = classes + " " + classes_height_fill_portion + " height-fill-" + to_string(
                portion
              );
              loop$node = node;
              loop$has = (() => {
                let _pipe = has;
                let _pipe$1 = add3(_pipe, height_fill());
                return add3(_pipe$1, height());
              })();
              loop$transform = transform;
              loop$styles = prepend(
                new Single(
                  classes_any + "." + classes_column + " > " + dot(
                    "height-fill-" + to_string(portion)
                  ),
                  "flex-grow",
                  to_string(portion * 1e5)
                ),
                styles
              );
              loop$attrs = attrs;
              loop$children = children;
              loop$element_attrs = remaining;
            }
          } else {
            let $1 = render_height(height3);
            let add_to_flags;
            let new_class;
            let new_styles;
            add_to_flags = $1[0];
            new_class = $1[1];
            new_styles = $1[2];
            loop$classes = classes + " " + new_class;
            loop$node = node;
            loop$has = merge2(add_to_flags, add3(has, height()));
            loop$transform = transform;
            loop$styles = append(new_styles, styles);
            loop$attrs = attrs;
            loop$children = children;
            loop$element_attrs = remaining;
          }
        }
      } else if (attribute3 instanceof Nearby) {
        let location = attribute3[0];
        let elem = attribute3[1];
        let _block;
        if (elem instanceof Unstyled) {
          _block = styles;
        } else if (elem instanceof Styled) {
          let styles$1 = elem.styles;
          _block = append(styles$1, styles$1);
        } else if (elem instanceof Text2) {
          _block = styles;
        } else {
          _block = styles;
        }
        let new_styles = _block;
        loop$classes = classes;
        loop$node = node;
        loop$has = has;
        loop$transform = transform;
        loop$styles = new_styles;
        loop$attrs = attrs;
        loop$children = add_nearby_element(location, elem, children);
        loop$element_attrs = remaining;
      } else {
        let flag2 = attribute3[0];
        let component = attribute3[1];
        loop$classes = classes;
        loop$node = node;
        loop$has = add3(has, flag2);
        loop$transform = compose_transformation(transform, component);
        loop$styles = styles;
        loop$attrs = attrs;
        loop$children = children;
        loop$element_attrs = remaining;
      }
    }
  }
}
function encode_styles(options, stylesheet) {
  let _pipe = stylesheet;
  let _pipe$1 = map2(
    _pipe,
    (style2) => {
      let styled = render_style_rule(options, style2, new None());
      return [get_style_name(style2), array2(styled, string3)];
    }
  );
  return object2(_pipe$1);
}
function as_el() {
  return new AsEl();
}
function adjust(size3, height3, vertical) {
  return new FontSizing(vertical, divideFloat(height3, size3), size3);
}
function convert_adjustment(adjustment) {
  let line_height = 1.5;
  let base = line_height;
  let normal_descender = (line_height - 1) / 2;
  let old_middle = line_height / 2;
  let lines = toList([
    adjustment.capital,
    adjustment.baseline,
    adjustment.descender,
    adjustment.lowercase
  ]);
  let ascender = unwrap(
    max(lines, compare),
    adjustment.capital
  );
  let descender = unwrap(
    max(lines, reverse(compare)),
    adjustment.descender
  );
  let _block;
  let _pipe = lines;
  let _pipe$1 = filter(_pipe, (x) => {
    return x !== descender;
  });
  let _pipe$2 = max(_pipe$1, reverse(compare));
  _block = unwrap(_pipe$2, adjustment.baseline);
  let new_baseline = _block;
  let capital_vertical = 1 - ascender;
  let capital_size = divideFloat(1, ascender - new_baseline);
  let full_size = divideFloat(1, ascender - descender);
  let full_vertical = 1 - ascender;
  return new ConvertedAdjustment(
    adjust(full_size, ascender - descender, full_vertical),
    adjust(capital_size, ascender - new_baseline, capital_vertical)
  );
}
function typeface_adjustment(typefaces) {
  return fold(
    typefaces,
    new None(),
    (found, face) => {
      if (found instanceof Some) {
        return found;
      } else {
        if (face instanceof FontWith) {
          let adjustment = face.adjustment;
          if (adjustment instanceof Some) {
            let adjustment$1 = adjustment[0];
            return new Some(
              [
                font_adjustment_rules(convert_adjustment(adjustment$1).full),
                font_adjustment_rules(convert_adjustment(adjustment$1).capital)
              ]
            );
          } else {
            return found;
          }
        } else {
          return found;
        }
      }
    }
  );
}
function render_top_level_values(rules2) {
  let with_import = (font) => {
    if (font instanceof ImportFont) {
      let url = font[1];
      return new Some("@import url('" + url + "');");
    } else {
      return new None();
    }
  };
  let all_names = map2(rules2, first2);
  let font_imports = (typefaces) => {
    let _pipe2 = typefaces;
    let _pipe$12 = second(_pipe2);
    let _pipe$2 = map2(_pipe$12, with_import);
    let _pipe$3 = values(_pipe$2);
    return join(_pipe$3, "\n");
  };
  let font_adjustments = (name, typefaces) => {
    let $ = typeface_adjustment(typefaces);
    if ($ instanceof Some) {
      let adjustment = $[0];
      let _pipe2 = all_names;
      let _pipe$12 = map2(
        _pipe2,
        (other_name) => {
          return render_font_adjustment_rule(name, adjustment, other_name);
        }
      );
      return join(_pipe$12, "");
    } else {
      return join(
        map2(
          all_names,
          (other_name) => {
            return render_null_adjustment_rule(name, other_name);
          }
        ),
        ""
      );
    }
  };
  let font_imports_rules = join(map2(rules2, font_imports), "\n");
  let _block;
  let _pipe = rules2;
  let _pipe$1 = map2(
    _pipe,
    (t) => {
      return font_adjustments(first2(t), second(t));
    }
  );
  _block = join(_pipe$1, "\n");
  let font_adjustments_rules = _block;
  return font_imports_rules + "\n" + font_adjustments_rules;
}
function to_style_sheet_string(options, stylesheet) {
  let combine = (rendered, style2) => {
    let rules3;
    let top_level_acc;
    rules3 = rendered[0];
    top_level_acc = rendered[1];
    return [
      append(rules3, render_style_rule(options, style2, new None())),
      (() => {
        let $2 = top_level_value(style2);
        if ($2 instanceof Some) {
          let top_level2 = $2[0];
          return prepend(top_level2, top_level_acc);
        } else {
          return top_level_acc;
        }
      })()
    ];
  };
  let $ = fold(stylesheet, [toList([]), toList([])], combine);
  let rules2;
  let top_level;
  rules2 = $[0];
  top_level = $[1];
  return render_top_level_values(top_level) + join(rules2, "");
}
var div2 = /* @__PURE__ */ new Generic();
var focus_default_style = /* @__PURE__ */ new FocusStyle(
  /* @__PURE__ */ new None(),
  /* @__PURE__ */ new None(),
  /* @__PURE__ */ new Some(
    /* @__PURE__ */ new Shadow(
      /* @__PURE__ */ new Rgba(0.608, 0.796, 1, 1),
      [0, 0],
      0,
      3
    )
  )
);
function options_to_record(options) {
  let combine = (record, opt) => {
    if (opt instanceof HoverOption) {
      let hover2 = opt[0];
      let $ = record.hover;
      if ($ instanceof Some) {
        return record;
      } else {
        return new OptionRecordBuidler(
          new Some(hover2),
          record.focus,
          record.mode
        );
      }
    } else if (opt instanceof FocusStyleOption) {
      let focus2 = opt[0];
      let $ = record.focus;
      if ($ instanceof Some) {
        return record;
      } else {
        return new OptionRecordBuidler(
          record.hover,
          new Some(focus2),
          record.mode
        );
      }
    } else {
      let mode = opt[0];
      let $ = record.mode;
      if ($ instanceof Some) {
        return record;
      } else {
        return new OptionRecordBuidler(
          record.hover,
          record.focus,
          new Some(mode)
        );
      }
    }
  };
  let and_finally = (record) => {
    return new OptionRecord(
      (() => {
        let $ = record.hover;
        if ($ instanceof Some) {
          let hoverable = $[0];
          return hoverable;
        } else {
          return new AllowHover();
        }
      })(),
      (() => {
        let $ = record.focus;
        if ($ instanceof Some) {
          let focusable = $[0];
          return focusable;
        } else {
          return focus_default_style;
        }
      })(),
      (() => {
        let $ = record.mode;
        if ($ instanceof Some) {
          let actual_mode = $[0];
          return actual_mode;
        } else {
          return new Layout();
        }
      })()
    );
  };
  return and_finally(
    fold_right(
      options,
      new OptionRecordBuidler(new None(), new None(), new None()),
      combine
    )
  );
}
function create_element(rendered, context, children) {
  let gather = (acc, child) => {
    let htmls;
    let existing_styles;
    htmls = acc[0];
    existing_styles = acc[1];
    if (child instanceof Unstyled) {
      let html = child[0];
      return [prepend(html(context), htmls), existing_styles];
    } else if (child instanceof Styled) {
      let styles = child.styles;
      let html = child.html;
      let _block;
      let $ = is_empty2(existing_styles);
      if ($) {
        _block = styles;
      } else {
        _block = append(styles, existing_styles);
      }
      let new_styles = _block;
      return [prepend(html(new NoStyleSheet())(context), htmls), new_styles];
    } else if (child instanceof Text2) {
      let str = child[0];
      return [
        prepend(
          (() => {
            let $ = isEqual(context, new AsEl());
            if ($) {
              return text_element_fill(str);
            } else {
              return text_element(str);
            }
          })(),
          htmls
        ),
        existing_styles
      ];
    } else {
      return [htmls, existing_styles];
    }
  };
  let gather_keyed = (acc, item) => {
    let htmls;
    let existing_styles;
    htmls = acc[0];
    existing_styles = acc[1];
    let key2;
    let child;
    key2 = item[0];
    child = item[1];
    if (child instanceof Unstyled) {
      let html = child[0];
      return [prepend([key2, html(context)], htmls), existing_styles];
    } else if (child instanceof Styled) {
      let styles = child.styles;
      let html = child.html;
      let _block;
      let $ = is_empty2(existing_styles);
      if ($) {
        _block = styles;
      } else {
        _block = append(styles, existing_styles);
      }
      let new_styles = _block;
      return [
        prepend([key2, html(new NoStyleSheet())(context)], htmls),
        new_styles
      ];
    } else if (child instanceof Text2) {
      let str = child[0];
      return [
        prepend(
          [
            key2,
            (() => {
              let $ = isEqual(context, new AsEl());
              if ($) {
                return text_element_fill(str);
              } else {
                return text_element(str);
              }
            })()
          ],
          htmls
        ),
        existing_styles
      ];
    } else {
      return [htmls, existing_styles];
    }
  };
  if (children instanceof Unkeyed) {
    let unkeyed_children = children[0];
    let $ = fold_right(unkeyed_children, [toList([]), toList([])], gather);
    let unkeyed = $[0];
    let styles = $[1];
    let _block;
    let $1 = is_empty2(styles);
    if ($1) {
      _block = rendered.styles;
    } else {
      _block = append(rendered.styles, styles);
    }
    let new_styles = _block;
    if (new_styles instanceof Empty) {
      return new Unstyled(
        (_capture) => {
          return finalize_node(
            rendered.has,
            rendered.node,
            rendered.attributes,
            new Unkeyed(add_children2(unkeyed, rendered.children)),
            new NoStyleSheet(),
            _capture
          );
        }
      );
    } else {
      let all_styles = new_styles;
      return new Styled(
        all_styles,
        (embed_mode) => {
          return (layout2) => {
            return finalize_node(
              rendered.has,
              rendered.node,
              rendered.attributes,
              new Unkeyed(add_children2(unkeyed, rendered.children)),
              embed_mode,
              layout2
            );
          };
        }
      );
    }
  } else {
    let keyed_children = children[0];
    let $ = fold_right(
      keyed_children,
      [toList([]), toList([])],
      gather_keyed
    );
    let keyed = $[0];
    let styles = $[1];
    let _block;
    let $1 = is_empty2(styles);
    if ($1) {
      _block = rendered.styles;
    } else {
      _block = append(rendered.styles, styles);
    }
    let new_styles = _block;
    if (new_styles instanceof Empty) {
      return new Unstyled(
        (layout2) => {
          return finalize_node(
            rendered.has,
            rendered.node,
            rendered.attributes,
            new Keyed(
              add_keyed_children("nearby-element-pls", keyed, rendered.children)
            ),
            new NoStyleSheet(),
            layout2
          );
        }
      );
    } else {
      let all_styles = new_styles;
      return new Styled(
        all_styles,
        (embed_mode) => {
          return (layout2) => {
            return finalize_node(
              rendered.has,
              rendered.node,
              rendered.attributes,
              new Keyed(
                add_keyed_children(
                  "nearby-element-pls",
                  keyed,
                  rendered.children
                )
              ),
              embed_mode,
              layout2
            );
          };
        }
      );
    }
  }
}
function finalize_node(has, node, attributes, children, embed_mode, parent_context) {
  let create_node = (node_name, attrs) => {
    if (children instanceof Unkeyed) {
      let unkeyed = children[0];
      let _block2;
      if (node_name === "div") {
        _block2 = div;
      } else if (node_name === "p") {
        _block2 = p;
      } else {
        _block2 = (attr, c) => {
          return element2(node_name, attr, c);
        };
      }
      let node_fn = _block2;
      return node_fn(
        attrs,
        (() => {
          if (embed_mode instanceof NoStyleSheet) {
            return unkeyed;
          } else if (embed_mode instanceof StaticRootAndDynamic) {
            let opts = embed_mode[0];
            let styles = embed_mode[1];
            return embed_with(true, opts, styles, unkeyed);
          } else {
            let opts = embed_mode[0];
            let styles = embed_mode[1];
            return embed_with(false, opts, styles, unkeyed);
          }
        })()
      );
    } else {
      let keyed = children[0];
      return element3(
        node_name,
        attrs,
        (() => {
          if (embed_mode instanceof NoStyleSheet) {
            return keyed;
          } else if (embed_mode instanceof StaticRootAndDynamic) {
            let opts = embed_mode[0];
            let styles = embed_mode[1];
            return embed_keyed(true, opts, styles, keyed);
          } else {
            let opts = embed_mode[0];
            let styles = embed_mode[1];
            return embed_keyed(false, opts, styles, keyed);
          }
        })()
      );
    }
  };
  let _block;
  if (node instanceof Generic) {
    _block = create_node("div", attributes);
  } else if (node instanceof NodeName) {
    let node_name = node[0];
    _block = create_node(node_name, attributes);
  } else {
    let node_name = node[0];
    let internal = node[1];
    _block = element2(
      node_name,
      attributes,
      toList([
        create_node(
          internal,
          toList([
            class$(classes_any + " " + classes_single)
          ])
        )
      ])
    );
  }
  let html = _block;
  if (parent_context instanceof AsRow) {
    let $ = present(width_fill(), has) && !present(
      width_between(),
      has
    );
    if ($) {
      return html;
    } else {
      let $1 = present(align_right(), has);
      if ($1) {
        return u(
          toList([
            class$(
              join(
                toList([
                  classes_any,
                  classes_single,
                  classes_container,
                  classes_content_center_y,
                  classes_align_container_right
                ]),
                " "
              )
            )
          ]),
          toList([html])
        );
      } else {
        let $2 = present(center_x(), has);
        if ($2) {
          return s(
            toList([
              class$(
                join(
                  toList([
                    classes_any,
                    classes_single,
                    classes_container,
                    classes_content_center_y,
                    classes_align_container_center_x
                  ]),
                  " "
                )
              )
            ]),
            toList([html])
          );
        } else {
          return html;
        }
      }
    }
  } else if (parent_context instanceof AsColumn) {
    let $ = present(height_fill(), has) && !present(
      height_between(),
      has
    );
    if ($) {
      return html;
    } else {
      let $1 = present(center_y(), has);
      if ($1) {
        return s(
          toList([
            class$(
              join(
                toList([
                  classes_any,
                  classes_single,
                  classes_container,
                  classes_align_container_center_y
                ]),
                " "
              )
            )
          ]),
          toList([html])
        );
      } else {
        let $2 = present(align_bottom(), has);
        if ($2) {
          return u(
            toList([
              class$(
                join(
                  toList([
                    classes_any,
                    classes_single,
                    classes_container,
                    classes_align_container_bottom
                  ]),
                  " "
                )
              )
            ]),
            toList([html])
          );
        } else {
          return html;
        }
      }
    }
  } else {
    return html;
  }
}
function element4(context, node, attributes, children) {
  let _pipe = attributes;
  let _pipe$1 = reverse3(_pipe);
  let _pipe$2 = ((_capture) => {
    return gather_attr_recursive(
      context_classes(context),
      node,
      none3,
      new Untransformed(),
      toList([]),
      toList([]),
      new NoNearbyChildren(),
      _capture
    );
  })(_pipe$1);
  return create_element(_pipe$2, context, children);
}
function static_root(opts) {
  let $ = opts.mode;
  if ($ instanceof Layout) {
    return element2(
      "div",
      toList([]),
      toList([
        element2(
          "style",
          toList([]),
          toList([text2(rules())])
        )
      ])
    );
  } else if ($ instanceof NoStaticStyleSheet) {
    return text2("");
  } else {
    return element2(
      "elm-ui-static-rules",
      toList([property2("rules", string3(rules()))]),
      toList([])
    );
  }
}
function render_root(option_list, attributes, child) {
  let options = options_to_record(option_list);
  let _block;
  let $ = options.mode;
  if ($ instanceof NoStaticStyleSheet) {
    _block = (_capture) => {
      return new OnlyDynamic(options, _capture);
    };
  } else {
    _block = (_capture) => {
      return new StaticRootAndDynamic(options, _capture);
    };
  }
  let embed_style = _block;
  let _pipe = as_el();
  let _pipe$1 = element4(_pipe, div2, attributes, new Unkeyed(toList([child])));
  return to_html(_pipe$1, embed_style);
}
function to_style_sheet(options, style_sheet) {
  let $ = options.mode;
  if ($ instanceof Layout) {
    return div(
      toList([]),
      toList([
        element2(
          "style",
          toList([]),
          toList([text3(to_style_sheet_string(options, style_sheet))])
        )
      ])
    );
  } else if ($ instanceof NoStaticStyleSheet) {
    return div(
      toList([]),
      toList([
        element2(
          "style",
          toList([]),
          toList([text3(to_style_sheet_string(options, style_sheet))])
        )
      ])
    );
  } else {
    return element2(
      "elm-ui-rules",
      toList([property2("rules", encode_styles(options, style_sheet))]),
      toList([])
    );
  }
}
function embed_with(static$, opts, styles, children) {
  let _block;
  let _pipe = styles;
  let _pipe$1 = fold(
    _pipe,
    [new$(), render_focus_style(opts.focus)],
    reduce_styles
  );
  let _pipe$2 = second(_pipe$1);
  _block = ((_capture) => {
    return to_style_sheet(opts, _capture);
  })(_pipe$2);
  let dynamic_style_sheet = _block;
  if (static$) {
    return prepend(
      static_root(opts),
      prepend(dynamic_style_sheet, children)
    );
  } else {
    return prepend(dynamic_style_sheet, children);
  }
}
function embed_keyed(static_, opts, styles, children) {
  let _block;
  let _pipe = styles;
  let _pipe$1 = fold(
    _pipe,
    [new$(), render_focus_style(opts.focus)],
    reduce_styles
  );
  let _pipe$2 = second(_pipe$1);
  _block = ((_capture) => {
    return to_style_sheet(opts, _capture);
  })(_pipe$2);
  let dynamic_style_sheet = _block;
  if (static_) {
    return prepend(
      ["static-stylesheet", static_root(opts)],
      prepend(["dynamic-stylesheet", dynamic_style_sheet], children)
    );
  } else {
    return prepend(["dynamic-stylesheet", dynamic_style_sheet], children);
  }
}
function echo(value2, message, file, line) {
  const grey = "\x1B[90m";
  const reset_color = "\x1B[39m";
  const file_line = `${file}:${line}`;
  const inspector = new Echo$Inspector();
  const string_value = inspector.inspect(value2);
  const string_message = message === void 0 ? "" : " " + message;
  if (globalThis.process?.stderr?.write) {
    const string5 = `${grey}${file_line}${reset_color}${string_message}
${string_value}
`;
    globalThis.process.stderr.write(string5);
  } else if (globalThis.Deno) {
    const string5 = `${grey}${file_line}${reset_color}${string_message}
${string_value}
`;
    globalThis.Deno.stderr.writeSync(new TextEncoder().encode(string5));
  } else {
    const string5 = `${file_line}
${string_value}`;
    globalThis.console.log(string5);
  }
  return value2;
}
var Echo$Inspector = class {
  #references = /* @__PURE__ */ new Set();
  #isDict(value2) {
    try {
      return value2 instanceof Dict;
    } catch {
      return false;
    }
  }
  #float(float2) {
    const string5 = float2.toString().replace("+", "");
    if (string5.indexOf(".") >= 0) {
      return string5;
    } else {
      const index4 = string5.indexOf("e");
      if (index4 >= 0) {
        return string5.slice(0, index4) + ".0" + string5.slice(index4);
      } else {
        return string5 + ".0";
      }
    }
  }
  inspect(v) {
    const t = typeof v;
    if (v === true) return "True";
    if (v === false) return "False";
    if (v === null) return "//js(null)";
    if (v === void 0) return "Nil";
    if (t === "string") return this.#string(v);
    if (t === "bigint" || Number.isInteger(v)) return v.toString();
    if (t === "number") return this.#float(v);
    if (v instanceof UtfCodepoint) return this.#utfCodepoint(v);
    if (v instanceof BitArray) return this.#bit_array(v);
    if (v instanceof RegExp) return `//js(${v})`;
    if (v instanceof Date) return `//js(Date("${v.toISOString()}"))`;
    if (v instanceof globalThis.Error) return `//js(${v.toString()})`;
    if (v instanceof Function) {
      const args = [];
      for (const i of Array(v.length).keys())
        args.push(String.fromCharCode(i + 97));
      return `//fn(${args.join(", ")}) { ... }`;
    }
    if (this.#references.size === this.#references.add(v).size) {
      return "//js(circular reference)";
    }
    let printed;
    if (Array.isArray(v)) {
      printed = `#(${v.map((v2) => this.inspect(v2)).join(", ")})`;
    } else if (v instanceof List) {
      printed = this.#list(v);
    } else if (v instanceof CustomType) {
      printed = this.#customType(v);
    } else if (this.#isDict(v)) {
      printed = this.#dict(v);
    } else if (v instanceof Set) {
      return `//js(Set(${[...v].map((v2) => this.inspect(v2)).join(", ")}))`;
    } else {
      printed = this.#object(v);
    }
    this.#references.delete(v);
    return printed;
  }
  #object(v) {
    const name = Object.getPrototypeOf(v)?.constructor?.name || "Object";
    const props = [];
    for (const k of Object.keys(v)) {
      props.push(`${this.inspect(k)}: ${this.inspect(v[k])}`);
    }
    const body = props.length ? " " + props.join(", ") + " " : "";
    const head = name === "Object" ? "" : name + " ";
    return `//js(${head}{${body}})`;
  }
  #dict(map8) {
    let body = "dict.from_list([";
    let first3 = true;
    let key_value_pairs = [];
    map8.forEach((value2, key2) => {
      key_value_pairs.push([key2, value2]);
    });
    key_value_pairs.sort();
    key_value_pairs.forEach(([key2, value2]) => {
      if (!first3) body = body + ", ";
      body = body + "#(" + this.inspect(key2) + ", " + this.inspect(value2) + ")";
      first3 = false;
    });
    return body + "])";
  }
  #customType(record) {
    const props = Object.keys(record).map((label) => {
      const value2 = this.inspect(record[label]);
      return isNaN(parseInt(label)) ? `${label}: ${value2}` : value2;
    }).join(", ");
    return props ? `${record.constructor.name}(${props})` : record.constructor.name;
  }
  #list(list4) {
    if (list4 instanceof Empty) {
      return "[]";
    }
    let char_out = 'charlist.from_string("';
    let list_out = "[";
    let current = list4;
    while (current instanceof NonEmpty) {
      let element5 = current.head;
      current = current.tail;
      if (list_out !== "[") {
        list_out += ", ";
      }
      list_out += this.inspect(element5);
      if (char_out) {
        if (Number.isInteger(element5) && element5 >= 32 && element5 <= 126) {
          char_out += String.fromCharCode(element5);
        } else {
          char_out = null;
        }
      }
    }
    if (char_out) {
      return char_out + '")';
    } else {
      return list_out + "]";
    }
  }
  #string(str) {
    let new_str = '"';
    for (let i = 0; i < str.length; i++) {
      const char = str[i];
      switch (char) {
        case "\n":
          new_str += "\\n";
          break;
        case "\r":
          new_str += "\\r";
          break;
        case "	":
          new_str += "\\t";
          break;
        case "\f":
          new_str += "\\f";
          break;
        case "\\":
          new_str += "\\\\";
          break;
        case '"':
          new_str += '\\"';
          break;
        default:
          if (char < " " || char > "~" && char < "\xA0") {
            new_str += "\\u{" + char.charCodeAt(0).toString(16).toUpperCase().padStart(4, "0") + "}";
          } else {
            new_str += char;
          }
      }
    }
    new_str += '"';
    return new_str;
  }
  #utfCodepoint(codepoint2) {
    return `//utfcodepoint(${String.fromCodePoint(codepoint2.value)})`;
  }
  #bit_array(bits) {
    if (bits.bitSize === 0) {
      return "<<>>";
    }
    let acc = "<<";
    for (let i = 0; i < bits.byteSize - 1; i++) {
      acc += bits.byteAt(i).toString();
      acc += ", ";
    }
    if (bits.byteSize * 8 === bits.bitSize) {
      acc += bits.byteAt(bits.byteSize - 1).toString();
    } else {
      const trailingBitsCount = bits.bitSize % 8;
      acc += bits.byteAt(bits.byteSize - 1) >> 8 - trailingBitsCount;
      acc += `:size(${trailingBitsCount})`;
    }
    acc += ">>";
    return acc;
  }
};

// build/dev/javascript/facet/facet/element.mjs
function rgb(red, green, blue) {
  return new Rgba(red, green, blue, 1);
}
function oklch(a, b, c) {
  return new Oklch(a, b, c);
}
function shrink() {
  return new Content2();
}
function fill() {
  return new Fill(1);
}
function layout_with(options, attributes, child) {
  return render_root(
    options,
    flatten(
      toList([
        toList([
          html_class(
            join(
              toList([
                classes_root,
                classes_any,
                classes_single
              ]),
              " "
            )
          )
        ]),
        root_style(),
        attributes
      ])
    ),
    child
  );
}
function layout(attributes, child) {
  return layout_with(toList([]), attributes, child);
}
function text4(content) {
  return new Text2(content);
}
function el(attributes, child) {
  return element4(
    new AsEl(),
    div2,
    attributes,
    new Unkeyed(toList([child]))
  );
}
function width2(length3) {
  return new Width(length3);
}
function height2(length3) {
  return new Height(length3);
}
function row(attributes, children) {
  return element4(
    new AsRow(),
    div2,
    append(
      toList([
        html_class(
          classes_content_left + " " + classes_content_center_x
        ),
        width2(shrink()),
        height2(shrink())
      ]),
      attributes
    ),
    new Unkeyed(children)
  );
}
function padding_xy(x, y) {
  let x_float = identity(x);
  let y_float = identity(y);
  return new StyleClass(
    padding(),
    new PaddingStyle(
      "p-" + to_string(x) + "-" + to_string(y),
      y_float,
      x_float,
      y_float,
      x_float
    )
  );
}
function center_x2() {
  return new AlignX(new CenterX2());
}
function center_y2() {
  return new AlignY(new CenterY2());
}
function spacing2(pixels) {
  return new StyleClass(
    spacing(),
    new SpacingStyle(spacing_name(pixels, pixels), pixels, pixels)
  );
}
function pointer() {
  return new Class2(cursor(), classes_cursor_pointer);
}
function color_gray_100() {
  return oklch(0.967, 3e-3, 264.542);
}
function color_white() {
  return rgb(1, 1, 1);
}

// build/dev/javascript/facet/facet/element/background.mjs
function color(clr) {
  return new StyleClass(
    bg_color(),
    new Colored(
      "bg-" + format_color_class(clr),
      "background-color",
      clr
    )
  );
}

// build/dev/javascript/facet/facet/element/border.mjs
function width3(v) {
  return new StyleClass(
    border_width(),
    new BorderWidth("b-" + to_string(v), v, v, v, v)
  );
}
function solid() {
  return new Class2(border_style(), classes_border_solid);
}
function rounded(radius) {
  return new StyleClass(
    border_round(),
    new Single(
      "br-" + to_string(radius),
      "border-radius",
      to_string(radius) + "px"
    )
  );
}

// build/dev/javascript/facet/facet/element/font.mjs
function family(families) {
  return new StyleClass(
    font_family(),
    new FontFamily(
      fold(families, "ff-", render_font_class_name),
      families
    )
  );
}
function sans_serif() {
  return new SansSerif();
}

// build/dev/javascript/lustre/lustre/event.mjs
function is_immediate_event(name) {
  if (name === "input") {
    return true;
  } else if (name === "change") {
    return true;
  } else if (name === "focus") {
    return true;
  } else if (name === "focusin") {
    return true;
  } else if (name === "focusout") {
    return true;
  } else if (name === "blur") {
    return true;
  } else if (name === "select") {
    return true;
  } else {
    return false;
  }
}
function on(name, handler) {
  return event(
    name,
    map3(handler, (msg) => {
      return new Handler(false, false, msg);
    }),
    empty_list,
    never,
    never,
    is_immediate_event(name),
    0,
    0
  );
}
function on_click(msg) {
  return on("click", success(msg));
}

// build/dev/javascript/facet/facet/element/events.mjs
function on_click2(msg) {
  return new Attr(on_click(msg));
}
function on2(event_name, decoder) {
  return new Attr(on(event_name, decoder));
}
function key() {
  return at(toList(["key"]), string2);
}

// build/dev/javascript/facet/facet/element/input.mjs
function has_focus_style(attr) {
  if (attr instanceof StyleClass) {
    let $ = attr.style;
    if ($ instanceof PseudoSelector) {
      let $1 = $[0];
      if ($1 instanceof Focus) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}
function focus_default(attrs) {
  let $ = any(attrs, has_focus_style);
  if ($) {
    return new NoAttribute();
  } else {
    return html_class("focusable");
  }
}
function on_key_lookup(msg, decoder) {
  return on2(
    "keyup",
    then$(
      key(),
      (key2) => {
        let $ = decoder(key2);
        if ($ instanceof Some) {
          let msg$1 = $[0];
          return success(msg$1);
        } else {
          return failure(msg, "Key not handled");
        }
      }
    )
  );
}
function button(attrs, on_press, label) {
  return element4(
    as_el(),
    div2,
    prepend(
      width2(shrink()),
      prepend(
        height2(shrink()),
        prepend(
          html_class(
            classes_content_center_x + " " + classes_content_center_y + " " + classes_se_button + " " + classes_no_text_selection
          ),
          prepend(
            pointer(),
            prepend(
              focus_default(attrs),
              prepend(
                new Describe(new Button()),
                prepend(
                  new Attr(tabindex(0)),
                  (() => {
                    if (on_press instanceof Some) {
                      let msg = on_press[0];
                      return prepend(
                        on_click2(msg),
                        prepend(
                          on_key_lookup(
                            msg,
                            (code) => {
                              let c = code;
                              if (c === "Enter") {
                                return new Some(msg);
                              } else {
                                let c$1 = code;
                                if (c$1 === " ") {
                                  return new Some(msg);
                                } else {
                                  return new None();
                                }
                              }
                            }
                          ),
                          attrs
                        )
                      );
                    } else {
                      return prepend(
                        new Attr(disabled(true)),
                        attrs
                      );
                    }
                  })()
                )
              )
            )
          )
        )
      )
    ),
    new Unkeyed(toList([label]))
  );
}

// build/dev/javascript/facet/facet.mjs
var FILEPATH = "src/facet.gleam";
var Incr = class extends CustomType {
};
var Decr = class extends CustomType {
};
function init(_) {
  return 0;
}
function update2(model, msg) {
  if (msg instanceof Incr) {
    return model + 1;
  } else {
    return model - 1;
  }
}
function view(model) {
  let count = to_string(model);
  return row(
    toList([
      height2(fill()),
      width2(fill()),
      center_x2(),
      center_y2(),
      spacing2(10)
    ]),
    toList([
      button(
        toList([padding_xy(10, 4), width3(1)]),
        new Some(new Decr()),
        text4("-")
      ),
      el(
        toList([
          solid(),
          width3(1),
          padding_xy(10, 4),
          rounded(4),
          color(color_white())
        ]),
        text4(count)
      ),
      button(
        toList([padding_xy(10, 4), width3(1)]),
        new Some(new Incr()),
        text4("+")
      )
    ])
  );
}
function main() {
  let app = simple(
    init,
    update2,
    (model) => {
      return layout(
        toList([
          height2(fill()),
          width2(fill()),
          family(toList([sans_serif()])),
          color(color_gray_100())
        ]),
        view(model)
      );
    }
  );
  let $ = start3(app, "#app", void 0);
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "facet",
      24,
      "main",
      "Pattern match failed, no pattern matched the value.",
      { value: $, start: 570, end: 619, pattern_start: 581, pattern_end: 586 }
    );
  }
  return void 0;
}

// build/.lustre/entry.mjs
main();
