@extends('admin.layout.page-app')
@section('page_title', 'Threads')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Threads</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Threads</li>
                    </ol>
                </div>
            </div>

            <!-- Search -->
            <form action="{{ route('threads.index')}}" method="GET">
                <div class="page-search mb-3">
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text" id="basic-addon1">
                                <i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i>
                            </span>
                        </div>
                        <input type="text" name="input_search" value="@if(isset($_GET['input_search'])){{$_GET['input_search']}}@endif" class="form-control" placeholder="Search Threads" aria-label="Search" aria-describedby="basic-addon1">
                    </div>
                    <div class="sorting mr-2" style="width: 50%;">
                        <label>Sort by :</label>
                        <select class="form-control" name="input_artist" id="input_artist">
                            <option value="0" selected>All Artist</option>
                            @for ($i = 0; $i < count($artist); $i++)
                                <option value="{{ $artist[$i]['id'] }}" @if(isset($_GET['input_artist'])){{ $_GET['input_artist'] == $artist[$i]['id'] ? 'selected' : ''}} @endif>
                                    {{ $artist[$i]['user_name'] }}
                                </option>
                            @endfor
                        </select>
                    </div>
                    <div class="sorting mr-2" style="width: 50%;">
                        <label>Sort by :</label>
                        <select class="form-control" name="input_user" id="input_user">
                            <option value="0" selected>All User</option>
                            @for ($i = 0; $i < count($user); $i++) 
                                <option value="{{ $user[$i]['id'] }}" @if(isset($_GET['input_user'])){{ $_GET['input_user'] == $user[$i]['id'] ? 'selected' : ''}} @endif>
                                    {{ $user[$i]['full_name'] }}
                                </option>
                            @endfor
                        </select>
                    </div>
                    <div class="mr-3 ml-3">
                        <button class="btn btn-default" type="submit">SEARCH</button>
                    </div>
                </div>
            </form>

            <div class="row">
                @foreach ($data as $key => $value)
                <div class="col-12 col-sm-6 col-md-4 col-xl-3">
                    <div class="card video-card">
                        <div class="position-relative">
                            <img class="card-img-top" src="{{$value->image}}" alt="">
                            <ul class="list-inline overlap-control" aria-labelledby="dropdownMenuLink">
                                <li class="list-inline-item">
                                    <a class="btn" href="{{route('threads.comment.index', [$value->id])}}" title="Comment">
                                        <i class="fa-solid fa-comments fa-xl" class="dot-icon" style="color: #4e45b8;"></i>
                                    </a>
                                </li>
                            </ul>
                            <button class="btn play-btn-top video" title="Read" data-toggle="modal" data-target="#videoModal" data-description="{{$value->description}}" data-image="{{$value->image}}">
                                <i class="fa-solid fa-book-open-reader text-white fa-3x mr-2 mt-2"></i>  
                            </button>
                        </div>
                        <div class="card-body">
                            <h5 class="card-title">{{$value->description}}</h5>
                            <div class="d-flex justify-content-between card-details">
                                @if($value->user_type == 1 && isset($value->user) && $value->user != null)
                                    <p class="card-text">{{$value->user->full_name}}</p>
                                @elseif($value->user_type == 2 && isset($value->artist) && $value->artist != null)
                                    <p class="card-text">{{$value->artist->user_name}}</p>
                                @endif
                                <div class="d-flex text-align-center" title="Total Like">
                                    <span class="d-flex text-align-center mr-3">
                                        <i class="fa-solid fa-thumbs-up fa-xl mr-3" style="color:#4e45b8; margin-top:12px"></i>
                                        <h5 class="counting" data-count="{{no_format($value->total_like ?? 0)}}">{{no_format($value->total_like)}}</h5>
                                    </span>
                                </div>
                                @if($value->status == 1)
                                    <button class="btn btn-sm" id="{{$value->id}}" onclick="change_status({{$value->id}}, {{$value->status}})" style="background:#058f00; font-weight:bold; border: none; color: white;">Show</button>
                                @elseif($value->status == 0)
                                    <button class="btn btn-sm" id="{{$value->id}}" onclick="change_status({{$value->id}}, {{$value->status}})" style="background:#e3000b; font-weight:bold; border: none; color: white;">Hide</button>
                                @endif
                            </div>
                        </div>
                    </div>
                </div>
                @endforeach
            </div>

            <!-- Description Model -->
            <div class="modal fade" id="videoModal" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered modal-lg">
                    <div class="modal-content">
                        <div class="modal-body p-0 bg-transparent">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true" class="text-dark">&times;</span>
                            </button>
                            <img src="" alt="" id="image" width="300" height="300" style="padding: 10px;">
                            <p id="description" style="padding: 10px;"></p>
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

        // Sidebar Scroll Down
        sidebar_down(500);

        $("#input_user").select2();
        $("#input_artist").select2();

        $(function() {
            $(".video").click(function() {

                var theModal = $(this).data("target"),
                    description = $(this).attr("data-description"),
                    image = $(this).attr("data-image");

                $("#image").attr("src",image);
                $("#description").text(description);
            });
        });

        function change_status(id, status) {

            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var url = "{{route('threads.show', '')}}" + "/" + id;
                $.ajax({
                    type: "GET",
                    url: url,
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    },
                    data: id,
                    success: function(resp) {
                        $("#dvloader").hide();
                        if (resp.status == 200) {
                            if (resp.Status_Code == 1) {

                                $('#' + id).text('Show');
                                $('#' + id).css({
                                    "background": "#058f00",
                                    "color": "white",
                                    "font-weight": "bold",
                                    "border": "none"
                                });
                            } else {

                                $('#' + id).text('Hide');
                                $('#' + id).css({
                                    "background": "#e3000b",
                                    "color": "white",
                                    "font-weight": "bold",
                                    "border": "none"
                                });
                            }
                        } else {
                            toastr.error(resp.errors);
                        }
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#dvloader").hide();
                        toastr.error(errorThrown, textStatus);
                    }
                });
            } else {
                toastr.error('You have no right to add, edit, and delete.');
            }
        };
    </script>
@endsection