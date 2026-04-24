@extends('admin.layout.page-app')
@section('page_title', __('Label.Dashboard'))

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">{{__('Label.Dashboard')}}</h1>

            <!-- First Counter -->
            <div class="row counter-row">
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color1-card">
                        <i class="fa-solid fa-users fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color1-viewall" href="{{ route('user.index')}}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter">
                            <p class="p-0 m-0 counting" data-count="{{no_format($UserCount ?? 0)}}">{{no_format($UserCount ?? 0)}}</p>
                            <span>{{__('Label.Users')}}</span>
                        </h2>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color2-card">
                        <i class="fa-solid fa-user-tie fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color2-viewall" href="{{route('artist.index')}}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter">
                            <p class="p-0 m-0 counting" data-count="{{no_format($ArtistCount ?? 0)}}">{{no_format($ArtistCount ?? 0)}}</p>
                            <span>Artist</span>
                        </h2>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color3-card">
                        <i class="fa-solid fa-microphone fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color3-viewall" href="{{ route('audiobook.index')}}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter">
                            <p class="p-0 m-0 counting" data-count="{{no_format($AudioBookCount ?? 0)}}">{{no_format($AudioBookCount ?? 0)}}</p>
                            <span>Audio Book</span>
                        </h2>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color4-card">
                        <i class="fa-solid fa-book fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color4-viewall" href="{{route('novel.index')}}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter">
                            <p class="p-0 m-0 counting" data-count="{{no_format($NovelCount ?? 0)}}">{{no_format($NovelCount ?? 0)}}</p>
                            <span>Novel</span>
                        </h2>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color5-card">
                        <i class="fa-solid fa-music fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color5-viewall" href="{{route('music.index')}}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter">
                            <p class="p-0 m-0 counting" data-count="{{no_format($MusicCount ?? 0)}}">{{no_format($MusicCount ?? 0)}}</p>
                            <span>Music</span>
                        </h2>
                    </div>
                </div>
            </div>
            <!-- Second Counter -->
            <div class="row counter-row">
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color6-card">
                        <i class="fa-solid fa-money-bill-1 fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color6-viewall" href="{{ route('transaction.index') }}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter mt-0">
                            <p class="p-0 m-0 counting" data-count="{{no_format($CurrentMounthCount ?? 00)}}">{{no_format($CurrentMounthCount ?? 00)}}</p>
                            <span style="font-size: 20px;">Month Earnings({{currency_code()}})</span>
                        </h2>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color7-card">
                        <i class="fa-solid fa-money-bill fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color7-viewall" href="{{ route('transaction.index') }}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter mt-4">
                            <p class="p-0 m-0 counting" data-count="{{no_format($EarningsCount ?? 00)}}">{{no_format($EarningsCount ?? 00)}}</p>
                            <span>Earnings ({{currency_code()}})</span>
                        </h2>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color8-card">
                        <i class="fa-solid fa-box-archive fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color8-viewall" href="{{ route('package.index') }}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter">
                            <p class="p-0 m-0 counting" data-count="{{no_format($PackageCount ?? 00)}}">{{no_format($PackageCount ?? 00)}}</p>
                            <span>Package</span>
                        </h2>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color9-card">
                        <i class="fa-solid fa-shapes fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color9-viewall" href="{{ route('category.index') }}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter">
                            <p class="p-0 m-0 counting" data-count="{{no_format($CategoryCount ?? 00)}}">{{no_format($CategoryCount?? 00)}}</p>
                            <span>Category</span>
                        </h2>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md col-lg-4 col-xl">
                    <div class="db-color-card color10-card">
                        <i class="fa-brands fa-threads fa-4x card-icon"></i>
                        <div class="dropdown dropright">
                            <a href="#" class="btn head-btn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa-solid fa-ellipsis-vertical fa-xl text-dark dot-icon mr-2"></i>
                            </a>
                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                                <a class="dropdown-item color10-viewall" href="{{ route('threads.index') }}">{{__('Label.View_All')}}</a>
                            </div>
                        </div>
                        <h2 class="counter">
                            <p class="p-0 m-0 counting" data-count="{{no_format($ThreadsCount ?? 00)}}">{{no_format($ThreadsCount ?? 00)}}</p>
                            <span>Threads</span>
                        </h2>
                    </div>
                </div>
            </div> 

            <!-- Join User Statistice && Package Statistice && Latest Threads -->
            <div class="row mb-2">
                <div class="col-12 col-xl-8 cart-bg">
                    <div>
                        <div class="box-title">
                            <h2 class="title"><i class="fa-solid fa-chart-column fa-lg mr-2"></i>Join Users Statistice (Current Year)</h2>
                            <a href="{{ route('user.index') }}" class="btn btn-link">{{__('Label.View_All')}}</a>
                        </div>
                        <div class="row mt-2 mb-2">
                            <div class="col-12 col-sm-12">
                                <Button id="year" class="btn btn-default">This Year</Button>
                                <Button id="month" class="btn btn-default">This Month</Button>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12 col-sm-12">
                                <canvas id="UserChart" width="100%" height="40px"></canvas>
                            </div>
                        </div>
                    </div>
                    <div>
                        <div class="box-title">
                            <h2 class="title"><i class="fa-solid fa-chart-column fa-lg mr-2"></i>Plan Earning Statistice (Current Year)</h2>
                            <a href="{{ route('transaction.index') }}" class="btn btn-link">{{__('Label.View_All')}}</a>
                        </div>
                        <div class="row">
                            <div class="col-12 col-sm-12">
                                <canvas id="MyChart" width="100%" height="40px"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-xl-4">
                    <div class="category-box">
                        <div class="box-title mt-0">
                            <h2 class="title"><i class="fa-solid fa-list fa-lg mr-2"></i>Latest Threads</h2>
                            <a href="{{ route('threads.index')}}" class="btn btn-link">{{__('Label.View_All')}}</a>
                        </div>
                        <div class="row">
                            @for ($i = 0; $i < count($latest_threads); $i++)
                                <div class="col-sm-6 col-xl-12">                       
                                    <div class="media suggested-video">
                                        <img class="mr-3 poster-img" src="{{$latest_threads[$i]['image']}}" alt="">
                                        <div class="media-body">
                                            <h5 class="mt-0 video-title">{{$latest_threads[$i]['description']}}</h5>
                                        </div>
                                    </div>
                                </div>
                            @endfor
                        </div>
                    </div>
                </div>
            </div>

            <!-- Most Famous Artist -->
            <div class="row mb-2">
                <div class="col-12 cart-bg">
                    <div class="box-title">
                        <h2 class="title"><i class="fa-solid fa-user-tie fa-lg mr-2"></i>Most Famous Artist</h2>
                        <a href="{{ route('artist.index')}}" class="btn btn-link">{{__('Label.View_All')}}</a>
                    </div>
                    <div class="row p-2 pl-3">
                        @if(isset($top_artist) && $top_artist != null)
                        @for ($i = 0; $i < count($top_artist); $i++) 
                            <div class="col-6 col-md-1 bg-white pt-2 pb-2 mr-2" style="border-radius: 10px;">
                                <div class="avatar-control">
                                    @if(isset($top_artist[$i]['artist']) != null && $top_artist[$i]['artist']->image)
                                    <img src="{{$top_artist[$i]['artist']->image}}" class="artist-image" />
                                    @else
                                    <img src="{{asset('assets/imgs/default.png')}}" class="artist-image" />
                                    @endif
                                </div>
                                <h6 class="mt-1 mb-0 artist-name">{{ $top_artist[$i]['artist']->user_name ?? "-" }}</h6>
                                <h6 class="mt-1 mb-0 artist-name counting"data-count="{{no_format($top_artist[$i]->total_count ?? 0)}}">{{no_format($top_artist[$i]->total_count ?? 0)}}</h6>
                            </div>
                            @if($i == 10)
                                @break;
                            @endif
                        @endfor
                        @endif
                    </div>
                </div>
            </div>

            <!-- Most Played Content && Best Category -->
            <div class="row mb-2">
                <div class="col-12 col-xl-8 cart-bg">
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
                                                    {{string_cut($most_play_audiobook[$i]['title'],65)}}
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
                                                    {{string_cut($most_play_novel[$i]['title'],65)}}
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
                                                    {{string_cut($most_play_music[$i]['title'],65)}}
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
                <div class="col-12 col-xl-4">
                    <div class="category-box">
                        <div class="box-title mt-0">
                            <h2 class="title"><i class="fa-solid fa-table-cells-large fa-lg mr-2"></i>Best Language</h2>
                            <a href="{{ route('language.index')}}" class="btn btn-link">{{__('Label.View_All')}}</a>
                        </div>
                        <div class="pt-3 mt-0">
                            <div class="row pr-3">
                                @for ($i = 0; $i < count($best_language); $i++)
                                    @if($i > 0 && (($i % 4) == 1 || ($i % 4) == 2))
                                        <div class="col-5 mb-2 pr-0">
                                            <img src="{{$best_language[$i]['image']}}" class="category-image">
                                            <div class="centered">{{$best_language[$i]['name']}}</div>
                                        </div>
                                        @else
                                        <div class="col-7 mb-2 pr-0">
                                            <img src="{{$best_language[$i]['image']}}" class="category-image">
                                            <div class="centered">{{$best_language[$i]['name']}}</div>
                                        </div>
                                    @endif
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
        var month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

        // User Statistice
        var cData = JSON.parse(`<?php echo $user_year; ?>`);
        var ctx = $("#UserChart");
        var data = {
            labels: month,
            datasets: [{
                label: 'Users',
                data: cData['sum'],
                backgroundColor: '#4e45b8',
            }],
        };
        var options = {
            responsive: true,
            legend: {
                title: "text",
                display: true,
                position: 'top',
                labels: {
                    fontSize: 16,
                    fontColor: "#000000",
                }
            },
            scales: {
                yAxes: [{
                    scaleLabel: {
                        display: true,
                        labelString: 'Total Count',
                        fontSize: 16,
                        fontColor: "#000000",
                    },
                }],
                xAxes: [{
                    scaleLabel: {
                        display: true,
                        labelString: 'Month',
                        fontSize: 16,
                        fontColor: "#000000",
                    }
                }]
            }
        };
        var chart1 = new Chart(ctx, {
            type: "bar",
            data: data,
            options: options
        });
        $("#year").on("click", function() {
            chart1.destroy();

            chart1 = new Chart(ctx, {
                type: "bar",
                data: data,
                options: options

            });
        });
        $("#month").on("click", function() {

            var date = new Date();
            var currentYear = date.getFullYear();
            var currentMonth = date.getMonth() + 1;
            const getDays = (year, month) => new Date(year, month, 0).getDate();
            const days = getDays(currentYear, currentMonth);

            var all1 = [];
            for (let i = 0; i < days; i++) {
                all1.push(i + 1);
            }

            chart1.destroy();
            var cData = JSON.parse(`<?php echo $user_month ?>`);

            var data = {
                labels: all1,
                datasets: [{
                    label: 'Users',
                    data: cData['sum'],
                    backgroundColor: '#4e45b8',
                }],
            };
            var options = {
                responsive: true,
                legend: {
                    title: "text",
                    display: true,
                    position: 'top',
                    labels: {
                        fontSize: 16,
                        fontColor: "#000000",
                    }
                },
                scales: {
                    yAxes: [{
                        scaleLabel: {
                            display: true,
                            labelString: 'Total Count',
                            fontSize: 16,
                            fontColor: "#000000",
                        },
                    }],
                    xAxes: [{
                        scaleLabel: {
                            display: true,
                            labelString: 'Date',
                            fontSize: 16,
                            fontColor: "#000000",
                        }
                    }]
                }
            };
            chart1 = new Chart(ctx, {
                type: "bar",
                data: data,
                options: options,
            });
        });

        // Plan Earning Statistice
        $(function() {
            //get the pie chart canvas
            var cData = JSON.parse(`<?php echo $package; ?>`);
            var ctx = $("#MyChart");
            var backcolor = ["#4e45b8", "#0b284d", "#173325", "#360331", "#2A445E", "#9b19f5", "#00bfa0", "#6D3A74", "#0a3603",  "#441552", "#349beb", "#b30000"];
            const datasetValue = [];
            for (let i = 0; i < cData['label'].length; i++) {
                datasetValue[i] = {
                    label: cData['label'][i],
                    data: cData['sum'][i],
                    backgroundColor: backcolor[i],
                }
            }
            //bar chart data
            var data = {
                labels: month,
                datasets: datasetValue
            };
            //options
            var options = {
                responsive: true,
                legend: {
                    title: "text",
                    display: true,
                    position: 'top',
                    labels: {
                        fontSize: 16,
                        fontColor: "#000000",
                    }
                },
                scales: {
                    yAxes: [{
                        scaleLabel: {
                            display: true,
                            labelString: 'Amount',
                            fontSize: 16,
                            fontColor: "#000000",
                        },
                    }],
                    xAxes: [{
                        scaleLabel: {
                            display: true,
                            labelString: 'Month',
                            fontSize: 16,
                            fontColor: "#000000",
                        }
                    }]
                }
            };
            //create bar Chart class object
            var chart1 = new Chart(ctx, {
                type: "bar",
                data: data,
                options: options
            });
        });
    </script>
@endsection