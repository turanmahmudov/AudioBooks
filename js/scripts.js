function get_catalog() {
    mainCatalogListModel.clear();
    indicator.opacity = 1;

    var url = 'https://librivox.org/api/feed/audiobooks/?format=json&extended=1&limit=50';

	var xhr = new XMLHttpRequest();
    xhr.open('GET', url);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            indicator.opacity = 0;

            var result = JSON.parse(xhr.responseText)['books'];
            var len = objLength(result);
            var i;
            var j = 0;
            for (i in result) {
                var archive_link = result[i]['url_iarchive'].replace("http://","https://") + '?output=json';

                mainCatalogListModel.append({"i":j, "id":result[i]['id'], "title":result[i]['title'], "author":result[i]['authors'][0]['first_name'] + ' ' + result[i]['authors'][0]['last_name'], "archivelink":archive_link, "image":''});

                fillCovers(j, len);
                j++;
            }
        }
    };

    xhr.send();
}

function fillCovers(j, len) {
    var xhrs = new XMLHttpRequest();
    xhrs.open('GET', mainCatalogListModel.get(j).archivelink);
    xhrs.onreadystatechange = function() {
        if (xhrs.readyState === 4) {
            var image = JSON.parse(xhrs.responseText.replace('<html>', '').replace('<head><title>302 Found</title></head>', '').replace('<body bgcolor="white">', '').replace('<center><h1>302 Found</h1></center>', '').replace('<hr><center>nginx/1.4.6 (Ubuntu)</center>', '').replace('</body>', '').replace('</html>', ''))['misc']['image'];

            mainCatalogListModel.setProperty(j, "image", image);
        }
    }

    xhrs.send();
}

function search_book(query) {
    searchCatalogListModel.clear();
    indicator.opacity = 1;

    var url = 'https://librivox.org/api/feed/audiobooks/?format=json&title=^'+query+'&extended=1&limit=100';

    var xhr = new XMLHttpRequest();
    xhr.open('GET', url);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            indicator.opacity = 0;

            var result = JSON.parse(xhr.responseText)['books'];
            var len = objLength(result);
            var i;
            var j = 0;
            for (i in result) {
                var archive_link = result[i]['url_iarchive'].replace("http://","https://") + '?output=json';

                searchCatalogListModel.append({"i":j, "id":result[i]['id'], "title":result[i]['title'], "author":result[i]['authors'][0]['first_name'] + ' ' + result[i]['authors'][0]['last_name'], "archivelink":archive_link, "image":''});

                j++;
            }
        }
    };

    xhr.send();
}

function get_book(id, image, archivelink) {
    var url = 'https://librivox.org/api/feed/audiobooks/?id='+id+'&format=json';

    var xhr = new XMLHttpRequest();
    xhr.open('GET', url);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            var result = JSON.parse(xhr.responseText)['books'];
            bookPage.title = result[0]['title'];
            bookDescriptionLabel.text = result[0]['description'];

            if (image == '') {
                var xhrs = new XMLHttpRequest();
                xhrs.open('GET', archivelink);
                xhrs.onreadystatechange = function() {
                    if (xhrs.readyState === 4) {
                        var images = JSON.parse(xhrs.responseText.replace('<html>', '').replace('<head><title>302 Found</title></head>', '').replace('<body bgcolor="white">', '').replace('<center><h1>302 Found</h1></center>', '').replace('<hr><center>nginx/1.4.6 (Ubuntu)</center>', '').replace('</body>', '').replace('</html>', ''))['misc']['image'];

                        bookImage.source = images;
                    }
                }

                xhrs.send();
            } else {
                bookImage.source = image;
            }
        }
    };

    xhr.send();
}

function get_book_rss(id) {
    indicator.opacity = 1;

    var url = 'https://librivox.org/rss/' + id;

    var xhr = new XMLHttpRequest();
    xhr.open('GET', url);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            indicator.opacity = 0;

            bookChaptersModel.xml = xhr.responseText;
            pageStack.push(bookPage);
        }
    };

    xhr.send();
}

function playNextSong() {
    if (active_index == bookChaptersModel.count) {
        active_index = 0;
    } else {
        active_index = active_index + 1;
    }
    console.log(active_index);
    player.source = bookChaptersModel.get(active_index).mp3_link;
    player.play();
}

function playPrevSong() {
    if (active_index == 0) {
        active_index = bookChaptersModel.count;
    } else {
        active_index = active_index - 1;
    }
    player.source = bookChaptersModel.get(active_index).mp3_link;
    player.play();
}

function changeIndex(index) {
    if (index == '0') {
        bookListenItem.visible = true;
        bookChaptersItem.visible = false;
        bookDescriptionItem.visible = false;
    } else if (index == '1') {
        bookListenItem.visible = false;
        bookChaptersItem.visible = true;
        bookDescriptionItem.visible = false;
    } else if (index == '2') {
        bookListenItem.visible = false;
        bookChaptersItem.visible = false;
        bookDescriptionItem.visible = true;
    }
}

function durationToString(duration) {
    var minutes = Math.floor((duration/1000) / 60);
    var seconds = Math.floor((duration/1000)) % 60;
    // Make sure that we never see "NaN:NaN"
    if (minutes.toString() == 'NaN')
        minutes = 0;
    if (seconds.toString() == 'NaN')
        seconds = 0;
    return minutes + ":" + (seconds<10 ? "0"+seconds : seconds);
}

function objLength(obj){
  var i=0;
  for (var x in obj){
    if(obj.hasOwnProperty(x)){
      i++;
    }
  }
  return i;
}
