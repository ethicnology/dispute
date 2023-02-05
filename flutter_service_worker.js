'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "favicon.png": "ea8587d8e1a34b99014bbc512b18f646",
"icons/Icon-192.png": "f518fa3b5a1623356cf288f76ba77ef5",
"icons/Icon-512.png": "136deec7b056ecb47d7ea3db6cd26e86",
"icons/Icon-maskable-512.png": "136deec7b056ecb47d7ea3db6cd26e86",
"icons/Icon-maskable-192.png": "f518fa3b5a1623356cf288f76ba77ef5",
"flutter.js": "1cfe996e845b3a8a33f57607e8b09ee4",
"assets/NOTICES": "09b75b58702cbfe3c58c2cf739dbc4af",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/assets/dispute-logo.png": "f3f20a757b6a976a2127f9000dc7c8d4",
"assets/AssetManifest.json": "c791ef6ca8a53ef1301d667a29dcd6d5",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"manifest.json": "4a7882f2f178c9e80a805be208b5aa7f",
"main.dart.js": "b207c640cf360b4e35f7b9b512bf6916",
".git/config": "5b603c2c0801a9ded3b79159fc38b404",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "295db3b6f81bd9add842e64fca23a539",
".git/logs/refs/heads/main": "295db3b6f81bd9add842e64fca23a539",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/index": "12222fa0aa328d03119c2a05c02099ec",
".git/COMMIT_EDITMSG": "45c9eb7fa6e6a781268f8a3b8d62d8b9",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
".git/objects/9d/f68a9adca9a385163629b762c8edb373953f0d": "506c2908657fb97ad610e82bb7be6e3b",
".git/objects/8c/99266130a89547b4344f47e08aacad473b14e0": "41375232ceba14f47b99f9d83708cb79",
".git/objects/e0/2012ca0a73da86edd7614aebdc24f350669305": "4cb516f7f367eb8387729d8cfc7cf9b2",
".git/objects/ad/132ba54ff876bb4d9fd54c0a8d48b03dbdaf02": "5ccb546b1fb278832a93acf42c6974e7",
".git/objects/78/c61eb85f6744c59228584aec586429a072a748": "5ef89505cbe5ffab9b5713a5c36b8931",
".git/objects/de/28db843d7df6ed23b8a7526f6b6b4a83425fe7": "797e4f7b3d8dced098c51679ff33e848",
".git/objects/81/cd149b57f8467c09c72a39fe7d2651cd4d5326": "c104dc8a13288f4ae68ae2775a7202a6",
".git/objects/81/becf2a9ecefa346d5ba5ffda64856ac61869c5": "e1d9092201a5012843bf0e474729883c",
".git/objects/74/968b5887af0aa338b43d461cc27f7957937132": "4c2ed4713d9ea5638db54aced73767a1",
".git/objects/6a/562868741911ffc3a5345f3c094a71eb0d073d": "ad3237b80e6dc65be0e2000c6c0a445f",
".git/objects/cd/22076013ce8b84475eae9bb4cd6c60b5460fbe": "81c620e2d6cbe5638d6c90ee25886389",
".git/objects/c8/e704ae5be97a33979500141edfac4ddf6fc10c": "a32ac83506ec1d08e34e8f93cd0347e4",
".git/objects/1e/eb7ed759740bf4dbd928dd087a98dbf3b3a6de": "0789514868e2290b2ed93c3d73c4db4b",
".git/objects/1a/b847b818dec389fb43fb9da80637c02e27d3d3": "8af286f2a069534106d53e8c037b0a4a",
".git/objects/fa/7fc56cbbb0d811e756896f9ca4c097378dc36c": "fc96368c2e7ad082aa307efb28f5417c",
".git/objects/48/a28b62c026b2bf8b46bbab32457c8bd1215749": "cb2f680990389ef3577ba2d0de650775",
".git/objects/87/164c988c887c4840df7f44d6a78c7c340e8819": "d8a05fb241329a667c66b64319c3886d",
".git/objects/69/789da227ce89c27c5f05889a95cc1768b9fc41": "a3b4faf91e4a70f6022d90dfbf6ee388",
".git/objects/0b/f9deb1c475cb02d669db40c8503e15cd791186": "749a23228baf11490d35356d59427bb2",
".git/objects/84/aded478362018da2b257dc38b39807ae425746": "c71c50dffc8d0ada59d23e24a6bcd5db",
".git/objects/76/6e7c008536b39df0a144aaaacbc748e951084e": "f58c4b477e44c5c0946899bad69a88ce",
".git/objects/dd/3398bfd62887187d8e0e809e0a87f7187ab2c9": "4272dff788ba5be735ae38b3f77a806d",
".git/objects/dd/d69501ba092d8597b31d6714885a3cbbaa9a20": "b7ae39f6a66020187dcb9751ff889fe5",
".git/objects/56/cdea037f3b97fa33537afb1649a6c8ee62b816": "c951bed27e2cb2665989d64abe18328c",
".git/objects/3a/bf18c41c58c933308c244a875bf383856e103e": "30790d31a35e3622fd7b3849c9bf1894",
".git/objects/a5/270ef3ca76bb36e1a916c0c429909c0f8ed002": "4b95c9cdc320e8364e8410d2b67eeb61",
".git/objects/cc/5725b315760d100f6386e6bbf09af8fe57a9f1": "29c19352d2bee0821600856656c95791",
".git/objects/41/5c059c8094b888b0159fdedfd4e3cb08a8028e": "86914685ccd40e82a7fe5b70459fb9f7",
".git/objects/04/4aa11ee0dc73c1678d2462c9f3425cc66f2981": "f93c593fe1f522b98552ca71510e2471",
".git/objects/66/c28b786d5adea059b7301859be544a9c7ee010": "61d73a0043b05f3d5d9543edf6cafe90",
".git/objects/12/5c284dc2bbed823ed6389e50cc75a8a1ef2351": "9ab0bcea773dc4fd6ef989aef459b28a",
".git/objects/55/919b0b32f21410d9755ffbe64aeb2d07650744": "ffb88073b04c5f9454f1e7f08edc733c",
".git/objects/7c/fb6f962bdb8c4b610bb1bb25b6c4361f9d20e8": "20235224869b650fc9ceb371e56bb5c9",
".git/objects/6c/19f70897c2020ba7879cc747dce4447f905609": "91c529e1ff40db2f0a2105bfa0abe180",
".git/objects/37/7ead7488ba04497de54363ee4e4436edf85774": "d08a584d3f7b4fb2a65c159d695456ff",
".git/objects/49/938d3f0c07beb7194c72b623c46ebc2acc28a1": "c52513b902ead034bc9a32ad0ecef9b8",
".git/objects/49/dc7139fbd044ca6d60f2a0c692f930b4484d7e": "921c1a013f5585c66fd933634e4093d7",
".git/objects/88/196d140889ae2fca5d66bbce595898ea5b6a82": "2e82246f1986bd2ad7984833b4599a4b",
".git/objects/92/fd5abfc9459de2d91026706273dbd32ebdbf00": "7f0975daf507fba0387ecaeffe38d377",
".git/objects/ec/f9e395ddd2d17e4b556cdb04aa26e3cc799990": "536d251aaed46d0f3a73e72916bb6c27",
".git/objects/7f/2f9936ba947641f8b56b53b283f1142370aa5d": "7add9067e089a015a7d6ef92f7efe962",
".git/objects/4b/ce11f832f26ee264d95b6790237601cf5a6088": "d9243641979aa81a886b057ab392745a",
".git/objects/73/a5ca9e6ea457a8e87e3e88047b9268f15bb75b": "437e873491b95548ba60fecc00fa7933",
".git/objects/b8/1704df85d242b0988648be4486d11d9501cc44": "46ad04cf19adc550e56a23087852bae2",
".git/objects/44/62a544fe699cec9be4a2ac1bb50cb501a6b45c": "fff3c60d5e2743e46239ca41459e1cc3",
".git/objects/d2/bcf5f0787937f30878d44041275c53f1be485c": "771955305632aa96f3806dfb822bdbb6",
".git/objects/d2/ec7b2d6b1fe0efb8a32647af8fd9e0ad93ea49": "a31d0f7ffc4760500e3d50b0fed550cd",
".git/objects/93/5fd9002c50c660748d738748d03e2c64056342": "05e1b76f5fc7c23983079ac753846c0f",
".git/objects/2b/2c3a562b375d8b8666585df340e8f3868f38a8": "92a5ead6e841d0afb413c30b02850499",
".git/objects/ca/534ed39b1343817b790b849180964b7cafd9ba": "1bef962347050973b74494f953e86d8b",
".git/objects/b4/c2ba3aa40a3cd92b98a57498aa89d2100751bc": "ad063338e6427adc742bf1f20513ea41",
".git/objects/3f/7682a6e830e34f27e98a37d386fa63b2985df4": "1acac7a08041d4c873c649de6751474c",
".git/objects/33/d73d7ca911f651c2f6ad679f856d5ae1a245b4": "587874aae042b5edf0e7b73805f0fdc4",
".git/objects/97/8746b5424d1212460133977131fc5ef0971abb": "3cc094294d4d3275ff02b12eff5e10c3",
".git/objects/2a/5f98b0b7a2d74f7be7da73fd6c3f11abe24430": "7805b473bb659011633ccb5ed64143fb",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/refs/heads/main": "f6f5baa37c8ee753933e8e5e10943d83",
"index.html": "c92cecc7d690a7154f084410b54d06c0",
"/": "c92cecc7d690a7154f084410b54d06c0",
"canvaskit/canvaskit.wasm": "3de12d898ec208a5f31362cc00f09b9e",
"canvaskit/canvaskit.js": "97937cb4c2c2073c968525a3e08c86a3",
"canvaskit/profiling/canvaskit.wasm": "371bc4e204443b0d5e774d64a046eb99",
"canvaskit/profiling/canvaskit.js": "c21852696bc1cc82e8894d851c01921a",
"version.json": "0874c6cb6d4143bd1105ce54ad542313"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
