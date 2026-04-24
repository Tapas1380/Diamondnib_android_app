@extends('artist.layout.page-app')
@section('page_title', 'Music')

@section('content')
    @include('artist.layout.sidebar')

    <div class="right-content">
        @include('artist.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Music</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('artist.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Music</li>
                    </ol>
                </div>
            </div>

            <!-- Search -->
            <form action="{{ route('amusic.index')}}" method="GET">
                <div class="page-search mb-3">
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text" id="basic-addon1">
                                <i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i>
                            </span>
                        </div>
                        <input type="text" name="input_search" value="@if(isset($_GET['input_search'])){{$_GET['input_search']}}@endif" class="form-control" placeholder="Search Music" aria-label="Search" aria-describedby="basic-addon1">
                    </div>
                    <div class="sorting mr-2" style="width: 55%;">
                        <label>Sort by :</label>
                        <select class="form-control" name="input_category" id="input_category">
                            <option value="0" selected>All Category</option>
                            @for ($i = 0; $i < count($category); $i++) 
                            <option value="{{ $category[$i]['id'] }}" @if(isset($_GET['input_category'])){{ $_GET['input_category'] == $category[$i]['id'] ? 'selected' : ''}} @endif>
                                {{ $category[$i]['name'] }}
                            </option>
                            @endfor
                        </select>
                    </div>
                    <div class="sorting mr-2" style="width: 55%;">
                        <label>Sort by :</label>
                        <select class="form-control" name="input_language" id="input_language">
                            <option value="0" selected>All Language</option>
                            @for ($i = 0; $i < count($language); $i++) 
                            <option value="{{ $language[$i]['id'] }}" @if(isset($_GET['input_language'])){{ $_GET['input_language'] == $language[$i]['id'] ? 'selected' : ''}} @endif>
                                {{ $language[$i]['name'] }}
                            </option>
                            @endfor
                        </select>
                    </div>
                    <button class="btn btn-default" type="submit">SEARCH</button>
                </div>
            </form>

            <div class="row">
                <div class="col-12 col-sm-6 col-md-4 col-xl-3">
                    <a href="{{ route('amusic.create') }}" class="add-video-btn">
                        <i class="fa-regular fa-square-plus fa-3x icon" style="color: #818181;"></i>
                        Add New Music
                    </a>
                </div>

                @foreach ($data as $key => $value)
                <div class="col-12 col-sm-6 col-md-4 col-xl-3">
                    <div class="card video-card">
                        <div class="position-relative">
                            <img class="card-img-top" src="{{$value->portrait_img}}" alt="">
                            @if($value->music_upload_type == "server_video")
                            <button class="btn play-btn-top video" data-toggle="modal" data-target="#videoModal" data-video="{{$value->music}}" data-image="{{$value->landscape_img}}">
                                <i class="fa-regular fa-circle-play text-white fa-4x mr-2 mt-2"></i>
                            </button>
                            @endif
                            <ul class="list-inline overlap-control" aria-labelledby="dropdownMenuLink">
                                <li class="list-inline-item">
                                    <a class="btn" href="{{route('amusic.edit', [$value->id])}}" title="Edit">
                                        <i class="fa-solid fa-pen-to-square fa-xl" class="dot-icon" style="color: #4e45b8;"></i>
                                    </a>
                                </li>
                                <li class="list-inline-item">
                                    <a class="btn" href="{{route('amusic.show', [$value->id])}}" title="Delete" onclick="return confirm('Are you sure !!! You want to Delete this Music ?')">
                                        <i class="fa-solid fa-trash-can fa-xl" class="dot-icon" style="color: #4e45b8;"></i>
                                    </a>
                                </li>
                            </ul>
                        </div>
                        <div class="card-body">
                            <h5 class="card-title">{{$value->title}}</h5>
                            <div class="d-flex justify-content-between">
                                @if($value->status == 1)
                                <button class="btn btn-sm" style="background:#058f00; font-weight:bold; border: none; color: white;" title="Show">Show</button>
                                @elseif($value->status == 0)
                                <button class="btn btn-sm" style="background:#e3000b; font-weight:bold; border: none; color: white;" title="Hide">Hide</button>
                                @endif

                                <div class="d-flex text-align-center" title="Total Play">
                                    <span class="d-flex text-align-center mr-3">
                                        <i class="fa-solid fa-play fa-xl mr-3" style="color:#4e45b8; margin-top:12px"></i>
                                        <h5 class="counting" data-count="{{no_format($value->total_played ?? 0)}}">{{no_format($value->total_played)}}</h5>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                @endforeach

            </div>

            <!-- Music Model -->
            <div class="modal fade" id="videoModal" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered modal-lg">
                    <div class="modal-content">
                        <div class="modal-body p-0 bg-transparent">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true" class="text-dark">&times;</span>
                            </button>
                            <video controls width="800" height="500" preload='none' poster="" id="theVideo" controlsList="nodownload noplaybackrate" disablepictureinpicture>
                                <source src="">
                            </video>
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
        $("#input_category").select2();
        $("#input_language").select2();

        $(function() {
            $(".video").click(function() {
                var theModal = $(this).data("target"),
                    videoSRC = $(this).attr("data-video"),
                    videoPoster = $(this).attr("data-image"),
                    videoSRCauto = videoSRC + "";

                $(theModal + ' source').attr('src', videoSRCauto);
                $(theModal + ' video').attr('poster', videoPoster);
                $(theModal + ' video').load();
                $(theModal + ' button.close').click(function() {
                    $(theModal + ' source').attr('src', videoSRC);
                });
            });
        });
        $("#videoModal .close").click(function() {
            theVideo.pause()
        });
    </script>
@endsection