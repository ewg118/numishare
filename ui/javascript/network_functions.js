/*******
FORCED NETWORK GRAPH FUNCTIONS FOR D3PLUS
Modified: June 2021
Function: These are the functions for generating a forced network graph for die and type pages when a die study is actived.
 *******/
$(document).ready(function () {
    var collection_type = $('#collection_type').text();
    var path = '../';
    
    /**** RENDER CHART ****/
    $('.network-graph').each(function () {
        var id = $(this).attr('id');
        
        var urlParams = {
        };
        
        if (collection_type == 'cointype') {
            urlParams[ 'type'] = $('#recordId').text();
            urlParams[ 'namedGraph'] = $(this).attr('namedGraph');
        } else if (collection_type == 'die') {
            urlParams[ 'die'] = $('#recordId').text();
            urlParams[ 'namedGraph'] = $(this).attr('namedGraph');
        } else if (collection_type == 'symbol') {
            urlParams[ 'uri'] = $('#objectURI').text();
        }
        
        renderNetworkGraph(id, path, collection_type, urlParams);
    });
});

//initiate a call to the getDieLinks JSON API and parse the resulting object into a d3plus Network
function renderNetworkGraph(id, path, collection_type, urlParams) {
    var api = (collection_type == 'symbol' ? 'getSymbolLinks': 'getDieLinks');
    
    //alert(urlParams);
    $('#' + id).removeClass('hidden');
    $('#' + id).height(600);
    
    $.get(path + 'apis/' + api, $.param(urlParams, true),
    function (data) {
        var nodeArray = data[ 'nodes'];
        var edgeArray = data[ 'edges'];
        
        const network = new d3plus.Network().config({
            links: edgeArray,
            linkSize: function (edge) {
                return edge.weight;
            },
            nodes: nodeArray,
            label: function (node) {
                if (node.hasOwnProperty('image')) {
                    return '';
                } else {
                    return node.label;
                }
            },
            tooltipConfig: {
                body: function (node) {
                    if (node.hasOwnProperty('image')) {
                        return '<div class="text-center"><strong>' + node.label + '</strong><br/><img src="' + node.image + '" style="width:32px"/></div>';
                    }
                }
            },
            shapeConfig: {
                backgroundImage: function (node) {
                    if (node.hasOwnProperty('image')) {
                        return node.image;
                    }
                }
            },
            color: function (node) {
                switch (node.side){
                    case 'obv':
                        return '#282f6b';
                        break;
                    case 'rev':
                        return '#b22200';
                        break;
                    case 'both':
                        return '#7e12cc';
                        break;
                    case 'first':
                        return '#6985c6';
                        break;
                    case 'second':
                        return '#b3c9fc';
                        break;
                    default:
                        return '#a8a8a8'
                }
            }
        }).on("click", function (node) {
            window.location.href = node.uri;
        }).select('#' + id).render();
    });
}