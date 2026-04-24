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

                <h1 class="primary-color install-title">{{__('Label.installation_process_started')}}</h1>
                <h1 class="install_sub_title">{{__('Label.we_are_checking_file_permissions_and_version')}}</h1>
                <ul class="list-group mt-3 install-list">
                    <li class="list-group-item">
                        @php
                            $phpVersion = number_format((float)phpversion(), 2, '.', '');
                        @endphp
                        @if ($phpVersion >= 8.1)
                            <i class="fa-solid fa-circle-check fa-xl text-success mr-2"></i>
                        @else
                            <i class="fa-solid fa-circle-xmark fa-xl text-danger mr-2"></i>
                        @endif
                        <span>{{__('Label.php_version_8.1')}}</span>
                    </li>
                    <li class="list-group-item">
                        @if ($permission['curl_enabled'])
                            <i class="fa-solid fa-circle-check fa-xl text-success mr-2"></i>
                        @else
                            <i class="fa-solid fa-circle-xmark fa-xl text-danger mr-2"></i>
                        @endif
                        {{__('Label.curl_enabled')}}
                    </li>
                    <li class="list-group-item">
                        @if ($permission['env_file'])
                            <i class="fa-solid fa-circle-check fa-xl text-success mr-2"></i>
                        @else
                            <i class="fa-solid fa-circle-xmark fa-xl text-danger mr-2"></i>
                        @endif
                        <b>{{__('Label.env')}}</b> {{__('Label.file_permission')}}
                    </li>
                    <li class="list-group-item">
                        @if ($permission['framework_file'])
                            <i class="fa-solid fa-circle-check fa-xl text-success mr-2"></i>
                        @else
                            <i class="fa-solid fa-circle-xmark fa-xl text-danger mr-2"></i>
                        @endif
                        <b>{{__('Label.storage/framework')}}</b> {{__('Label.file_permission')}}
                    </li>
                    <li class="list-group-item">
                        @if ($permission['logs_file'])
                            <i class="fa-solid fa-circle-check fa-xl text-success mr-2"></i>
                        @else
                            <i class="fa-solid fa-circle-xmark fa-xl text-danger mr-2"></i>
                        @endif
                        <b>{{__('Label.storage/log')}}</b> {{__('Label.file_permission')}}
                    </li>
                </ul>
                @if ($phpVersion >= 8.1 && $permission['curl_enabled'] == 1 && $permission['env_file'] == 1 && $permission['framework_file'] == 1 && $permission['logs_file'] == 1)
                    <a href="{{ route('step2',['token'=>bcrypt('step_2')]) }}" onclick="showLoder()" class="btn btn-install mt-3">{{__('Label.next')}}<i class="fa-solid fa-angles-right ml-2"></i></a>
                @endif
                
                <!-- Footer -->
                @include('installation.layout.footer')

            </div>
        </div>
        <div class="col-lg-6 install-bg-img d-none d-lg-block">
            <img src="{{ asset('assets/imgs/install_bg.png') }}" alt="Software Installation">
        </div>
    </div>
@endsection