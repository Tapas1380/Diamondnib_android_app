@extends('admin.layout.page-app')
@section('page_title', 'Wallet')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Wallet</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Wallet</li>
                    </ol>
                </div>
            </div>

            <!-- Search -->
            <form action="{{ route('wallet.index')}}" method="GET">
                <div class="page-search mb-3">
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text" id="basic-addon1">
                                <i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i>
                            </span>
                        </div>
                        <input type="text" name="input_search" value="@if(isset($_GET['input_search'])){{$_GET['input_search']}}@endif" class="form-control" placeholder="Search User Name, Email, Mobile Number, Coin" aria-label="Search" aria-describedby="basic-addon1">
                    </div>
                    <button class="btn btn-default" type="submit">SEARCH</button>
                </div>
            </form>

            <div class="row">
                @foreach ($data as $key => $value)
                <div class="col-xl-4 col-lg-6">
                    <div class="card p-4 video-card">
                        <div class="media text-secondary">
                            <img src="{{$value->image}}" class="mr-3 wallet-image" alt="Avatar Image">
                            <div class="media-body card-body pt-0">
                                <h4 class="mt-0 mb-2 text-dark card-title">{{$value->user_name}}</h4>
                                <ul class="list-unstyled">
                                    <li class="d-flex mb-1">
                                        <span>{{$value->email}}</span>
                                    </li>
                                    <li class="d-flex mb-1">
                                        <span>{{$value->mobile_number}}</span>
                                    </li>
                                    <li class="d-flex">
                                        <span><b>Coin : {{$value->wallet_coin}}</b></span>
                                    </li>
                                </ul>

                                <a href="{{ route('wallet.transaction', $value->id) }}" class="btn btn-md mw-150" style="background:#058f00; color:#fff; font-weight:bold; border:none">
                                    Transaction
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                @endforeach
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
        let sidebarHeight = $('.sidebar')[0].scrollHeight;
        sidebar_down(sidebarHeight);
    </script>
@endsection
