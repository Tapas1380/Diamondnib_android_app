@extends('artist.layout.page-app')
@section('page_title', __('Label.Dashboard'))

@section('content')
    @include('artist.layout.sidebar')

    <div class="right-content">
        @include('artist.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">{{__('Label.Dashboard')}}</h1>

            <!-- First Counter -->
            <div class="row counter-row">
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color1-card">
                        <i class="fa-solid fa-microphone fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color1-viewall" href="{{ route('aaudiobook.index')}}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter">
                            <p class="p-0 m-0 counting" data-count="{{no_format($AudioBookCount ?? 0)}}">{{no_format($AudioBookCount ?? 0)}}</p>
                            <span>Audio Book</span>
                        </h2>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color2-card">
                        <i class="fa-solid fa-book fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color2-viewall" href="{{route('anovel.index')}}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter">
                            <p class="p-0 m-0 counting" data-count="{{no_format($NovelCount ?? 0)}}">{{no_format($NovelCount ?? 0)}}</p>
                            <span>Novel</span>
                        </h2>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color3-card">
                        <i class="fa-brands fa-threads fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color3-viewall" href="{{ route('athreads.index')}}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter">
                            <p class="p-0 m-0 counting" data-count="{{no_format($ThreadsCount ?? 0)}}">{{no_format($ThreadsCount ?? 0)}}</p>
                            <span>Threads</span>
                        </h2>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color4-card">
                        <i class="fa-solid fa-music fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color4-viewall" href="{{route('amusic.index')}}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter">
                            <p class="p-0 m-0 counting" data-count="{{no_format($MusicCount ?? 0)}}">{{no_format($MusicCount ?? 0)}}</p>
                            <span>Music</span>
                        </h2>
                    </div>
                </div>
            </div>

            <!-- Most Played Content && Best Category -->
            <div class="row mb-2">
                <div class="col-12 cart-bg">
                    <div class="box-title">
                        <h2 class="title"><i class="fa-solid fa-chart-bar fa-lg mr-2"></i>Most Played Content</h2>
                    </div>

                    <ul class="nav nav-pills custom-tabs" id="pills-tab" role="tablist">
                        <li class="nav-item">
                            <a class="nav-link active" id="pills-audiobook-view-tab" data-toggle="pill" href="#pills-audiobook-view" role="tab" aria-controls="pills-audiobook-view" aria-selected="true">Audio Book</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" id="pills-novel-view-tab" data-toggle="pill" href="#pills-novel-view" role="tab" aria-controls="pills-novel-view" aria-selected="false">Novel</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" id="pills-music-view-tab" data-toggle="pill" href="#pills-music-view" role="tab" aria-controls="pills-music-view" aria-selected="false">Music</a>
                        </li>
                    </ul>

                    <div class="tab-content" id="pills-tabContent">
                        <div class="tab-pane fade show active" id="pills-audiobook-view" role="tabpanel" aria-labelledby="pills-audiobook-view-tab">
                            <div class="summary-table-card">
                                @for ($i = 0; $i < count($most_play_audiobook); $i++)
                                    <div class="border-card bg-white">
                                        <div class="row">
                                            <div class="col-1">
                                                {{$i + 1 .'.'}}
                                            </div>
                                            <div class="col-9">
                                                <span class="avatar-control">
                                                    <img src="{{$most_play_audiobook[$i]['portrait_img']}}" style='height:40px; width:40px' />
                                                    {{string_cut($most_play_audiobook[$i]['title'],125)}}
                                                </span>
                                            </div>
                                            <div class="col-2 d-flex justify-content-start">
                                                <i class="fa-solid fa-play mr-3 fa-xl primary-color"></i>   
                                                <p class="m-0 p-0 counting" data-count="{{no_format($most_play_audiobook[$i]['total_played'] ?? 00)}}"> {{no_format($most_play_audiobook[$i]['total_played'] ?? 00)}}</p>
                                            </div>
                                        </div>
                                    </div>
                                @endfor
                            </div>
                        </div>
                        <div class="tab-pane fade" id="pills-novel-view" role="tabpanel" aria-labelledby="pills-novel-view-tab">
                            <div class="summary-table-card">
                                @for ($i = 0; $i < count($most_play_novel); $i++)
                                    <div class="border-card bg-white">
                                        <div class="row">
                                            <div class="col-1">
                                                {{$i + 1 .'.'}}
                                            </div>
                                            <div class="col-9">
                                                <span class="avatar-control">
                                                    <img src="{{ $most_play_novel[$i]['portrait_img'] }}" style='height:40px; width:40px' />
                                                    {{string_cut($most_play_novel[$i]['title'],125)}}
                                                </span>
                                            </div>
                                            <div class="col-2 d-flex justify-content-start">
                                                <i class="fa-solid fa-play mr-3 fa-xl primary-color"></i>   
                                                <p class="m-0 p-0 counting" data-count="{{no_format($most_play_novel[$i]['total_played'] ?? 00)}}"> {{no_format($most_play_novel[$i]['total_played'] ?? 00)}}</p>
                                            </div>
                                        </div>
                                    </div>
                                @endfor
                            </div>
                        </div>
                        <div class="tab-pane fade" id="pills-music-view" role="tabpanel" aria-labelledby="pills-music-view-tab">
                            <div class="summary-table-card">
                                @for ($i = 0; $i < count($most_play_music); $i++)
                                    <div class="border-card bg-white">
                                        <div class="row">
                                            <div class="col-1">
                                                {{$i + 1 .'.'}}
                                            </div>
                                            <div class="col-9">
                                                <span class="avatar-control">
                                                    <img src="{{ $most_play_music[$i]['portrait_img'] }}" style='height:40px; width:40px' />
                                                    {{string_cut($most_play_music[$i]['title'],125)}}
                                                </span>
                                            </div>
                                            <div class="col-2 d-flex justify-content-start">
                                                <i class="fa-solid fa-play mr-3 fa-xl primary-color"></i>   
                                                <p class="m-0 p-0 counting" data-count="{{no_format($most_play_music[$i]['total_played'] ?? 00)}}"> {{no_format($most_play_music[$i]['total_played'] ?? 00)}}</p>
                                            </div>
                                        </div>
                                    </div>
                                @endfor
                            </div>  
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@section('pagescript')
    <script>
    </script>
@endsection