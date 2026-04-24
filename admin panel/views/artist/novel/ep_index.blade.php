@extends('artist.layout.page-app')
@section('page_title', 'Chapters')

@section('content')
    @include('artist.layout.sidebar')

    <div class="right-content">
        @include('artist.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Chapters</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('artist.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('anovel.index') }}">Novel</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Chapters</li>
                    </ol>
                </div>
            </div>

            <!-- Search -->
            <form action="{{ route('anovel.episode.index', $novel_id)}}" method="GET">
                <div class="page-search mb-3">
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text" id="basic-addon1">
                                <i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i>
                            </span>
                        </div>
                        <input type="text" name="input_search" value="@if(isset($_GET['input_search'])){{$_GET['input_search']}}@endif" class="form-control" placeholder="Search Chapters" aria-label="Search" aria-describedby="basic-addon1">
                    </div>
                    <div class="mr-3 ml-5">
                        <button class="btn btn-default" type="submit">SEARCH</button>
                    </div>
                    <div class="mr-3 ml-5" title="Sortable">
                        <button type="button" data-toggle="modal" data-target="#exampleModal" class="btn btn-default" style="border-radius: 10px;">
                            <i class="fa-solid fa-sort fa-2x"></i>
                        </button>
                    </div>
                </div>
            </form>

            <div class="row">
                <div class="col-12 col-sm-6 col-md-4 col-xl-3">
                    <a href="{{ route('anovel.episode.add', $novel_id) }}" class="add-video-btn">
                        <i class="fa-regular fa-square-plus fa-3x icon" style="color: #818181;"></i>
                        Add New Chapter
                    </a>
                </div>

                @foreach ($data as $key => $value)
                <div class="col-12 col-sm-6 col-md-4 col-xl-3">
                    <div class="card video-card">
                        <div class="position-relative">
                            @if($value->is_book_paid == 1)
                                <div class="ribbon ribbon-top-left"><span>Is Paid</span></div>
                            @endif

                            <img class="card-img-top" src="{{$value->image}}" alt="">
                            <ul class="list-inline overlap-control" aria-labelledby="dropdownMenuLink">
                                <li class="list-inline-item">
                                    <a class="btn" href="{{route('anovel.episode.edit', [$novel_id, $value->id])}}" title="Edit">
                                        <i class="fa-solid fa-pen-to-square fa-xl" class="dot-icon" style="color: #4e45b8;"></i>
                                    </a>
                                </li>
                                <li class="list-inline-item">
                                    <a class="btn" href="{{route('anovel.episode.delete', [$novel_id, $value->id])}}" title="Delete" onclick="return confirm('Are you sure !!! You want to Delete this Chapter ?')">
                                        <i class="fa-solid fa-trash-can fa-xl" class="dot-icon" style="color: #4e45b8;"></i>
                                    </a>
                                </li>
                            </ul>
                        </div>
                        <div class="card-body">
                            <h5 class="card-title">{{$value->name}}</h5>
                            <div class="d-flex justify-content-between">
                                <div class="d-flex text-align-center" title="Total Read">
                                    <span class="d-flex text-align-center mr-3">
                                        <i class="fa-solid fa-book-open-reader fa-xl mr-3" style="color:#4e45b8; margin-top:12px"></i>
                                        <h5 class="counting" data-count="{{no_format($value->total_book_played ?? 0)}}">{{no_format($value->total_book_played)}}</h5>
                                    </span>
                                </div>

                                @if($value->is_book_paid == 1)
                                    <h5><b>Coin : {{$value->is_book_coin}}</b></h5>
                                @endif
                            </div>
                        </div>
                    </div>
                </div>
                @endforeach
            </div>

            <!-- Sortable -->
            <div class="modal fade" id="exampleModal" tabindex="-1" data-backdrop="static" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title w-100 text-center" id="exampleModalLabel">Episode Sortable List</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close" id="close">
                                <span aria-hidden="true" class="text-dark">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <div id="ListId">
                                @foreach ($data as $key => $value)
                                <div id="{{$value->id}}" class="listitemClass mb-2" style="background-color: #e9ecef;border: 1px solid black;cursor: s-resize;">
                                    <p class="m-3">{{$value->name}}</p>
                                </div>
                                @endforeach
                            </div>
                        </div>
                        <div class="modal-footer justify-content-center">
                            <form enctype="multipart/form-data" id="save_episode_sortable">
                                @csrf
                                <input id="outputvalues" type="hidden" name="ids" value="" />
                                <div class="w-100 text-center">
                                    <button type="button" class="btn btn-default mw-120" onclick="save_episode_sortable()">{{__('Label.SAVE')}}</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pagination -->
            <div class="d-flex justify-content-between align-items-center">
                <div> Showing {{ $data->firstItem() }} to {{ $data->lastItem() }} of total {{$data->total()}} entries </div>
                <div class="pb-5"> {{ $data->links() }} </div>
            </div>
        </div>
    </div>
@endsection

@section('pagescript')
    <script>
        $("#ListId").sortable({
            update: function(event, ui) {
                getIdsOfList();
            }
        });
        function getIdsOfList() {
            var values = [];
            $('.listitemClass').each(function(index) {
                values.push($(this).attr("id")
                    .replace("imageNo", ""));
            });
            $('#outputvalues').val(values);
        }
        function save_episode_sortable() {

            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#save_episode_sortable")[0]);
                $.ajax({
                    type: 'POST',
                    url: '{{ route("anovel.episode.sortable") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'save_episode_sortable', '{{ route("anovel.episode.index", $novel_id)}}');
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#dvloader").hide();
                        toastr.error(errorThrown, textStatus);
                    }
                });
            } else {
                toastr.error('You have no right to add, edit, and delete.');
            }
        }
    </script>
@endsection