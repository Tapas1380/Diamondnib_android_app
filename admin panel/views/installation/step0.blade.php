@extends('installation.layout.page-app')

@section('content')
    <div class="row">
        <div class="col-md-12 col-lg-12 col-xl-6 d-flex flex-column justify-content-center">
            <div class="install-card">

                <!-- Alert MSG -->
                @if(session()->has('error'))
                    <div class="alert alert-danger alert-block">
                        <button type="button" class="close" data-dismiss="alert" title="Remove">X</button>
                        <strong>{{ Session::get('error') }}</strong>
                    </div>
                @elseif(session()->has('success'))
                    <div class="alert alert-danger alert-block">
                        <button type="button" class="close" data-dismiss="alert" title="Remove">X</button>
                        <strong>{{ Session::get('success') }}</strong>
                    </div>
                @endif

                <h1 class="primary-color install-title">{{__('Label.divinetech_software_installation')}}</h1>
                <h1 class="install_sub_title">{{__('Label.admin_panel_information_required')}}</h1>
                <ul class="list-group mt-3 install-list">
                    <li class="list-group-item">
                        <i class="fa-solid fa-circle mr-2"></i>
                        <span>{{__('Label.purchase_code')}}</span>
                    </li>
                    <li class="list-group-item">
                        <i class="fa-solid fa-circle mr-2"></i>
                        <span>{{__('Label.database_name')}}</span>
                    </li>
                    <li class="list-group-item">
                        <i class="fa-solid fa-circle mr-2"></i>
                        <span>{{__('Label.database_username')}}</span>
                    </li>
                    <li class="list-group-item">
                        <i class="fa-solid fa-circle mr-2"></i>
                        <span>{{__('Label.database_password')}}</span>
                    </li>
                    <li class="list-group-item">
                        <i class="fa-solid fa-circle mr-2"></i>
                        <span>{{__('Label.database_host')}}</span>
                    </li>
                </ul>
                <a href="{{ route('step1',['token'=>bcrypt('step_1')]) }}" onclick="showLoder()" class="btn btn-install mt-3">{{__('Label.get_started')}}<i class="fa-solid fa-angles-right ml-2"></i></a>

                <!-- Footer -->
                @include('installation.layout.footer')

            </div>
        </div>
        <div class="col-lg-6 install-bg-img d-none d-lg-block">
            <img src="{{ asset('assets/imgs/install_bg.png') }}" alt="Software Installation">
        </div>
    </div>
@endsection