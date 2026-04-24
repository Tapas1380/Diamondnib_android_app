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
				<div class="col-sm-10">
					<ol class="breadcrumb">
						<li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
						<li class="breadcrumb-item"><a href="{{ route('user.index') }}">{{__('Label.Users')}}</a></li>
						<li class="breadcrumb-item active" aria-current="page">Wallet</li>
					</ol>
				</div>
				<div class="col-sm-2 d-flex align-items-center justify-content-end">
					<a href="{{ route('user.index') }}" class="btn btn-default mw-120" style="margin-top:-14px">{{__('Label.Users List')}}</a>
				</div>
			</div>

            <!-- Counter -->
            <div class="row counter-row">
                <div class="col-6 col-sm-4 col-lg-4">
                    <div class="db-color-card color6-card">
                        <i class="fa-solid fa-wallet fa-4x card-icon"></i>
                        <h2 class="counter">
                            <p class="p-0 m-0">{{$data['wallet_coin'] ?? 0}}</p>
                            <span>Wallet Balance</span>
                        </h2>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-lg-4">
                    <div class="db-color-card color9-card">
                        <i class="fa-solid fa-arrow-right-arrow-left fa-4x card-icon"></i>
                        <h2 class="counter">
                            <p class="p-0 m-0">{{$total_transaction_coin ?? 0}}</p>
                            <span>Total Transaction Coin</span>
                        </h2>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-lg-4">
                    <div class="db-color-card color8-card">
                        <i class="fa-solid fa-money-bill-transfer fa-4x card-icon"></i>
                        <h2 class="counter">
                            <p class="p-0 m-0">{{$total_reward_coin ?? 0}}</p>
                            <span>Total Reward Coin</span>
                        </h2>
                    </div>
                </div>
            </div>

            <div class="table-responsive table">
                <table class="table table-striped text-center table-bordered" id="datatable">
                    <thead>
                        <tr style="background: #F9FAFF;">
                            <th>{{__('Label.#')}}</th>
                            <th>Content Type</th>
                            <th>Audio Book Type</th>
                            <th>Content</th>
                            <th>Episode</th>
                            <th>{{__('Label.Coin')}}</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
		</div>
	</div>
@endsection

@section('pagescript')
    <script>
        $(document).ready(function() {
            var table = $('#datatable').DataTable({
                searching: false,
                responsive: true,
                autoWidth: false,
                processing: true,
                serverSide: true,
                lengthMenu: [
                    [10, 100, 500, -1],
                    [10, 100, 500, "All"]
                ],
                language: {
                    paginate: {
                        previous: "<i class='fa-solid fa-chevron-left'></i>",
                        next: "<i class='fa-solid fa-chevron-right'></i>"
                    }
                },
                ajax: {
                    url: "{{ route('user.wallet', $id) }}",
                },
                columns: [{
                        data: 'DT_RowIndex',
                        name: 'DT_RowIndex'
                    },
                    {
                        data: 'content_type',
                        name: 'content_type',
                        render: function(data, type, full, meta) {
                            if (data == 1) {
                                return "Audio Book";
                            } else if(data == 2) {
                                return "Novel";
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'audiobook_type',
                        name: 'audiobook_type',
                        render: function(data, type, full, meta) {
                            if (data == 1) {
                                return "Audio";
                            } else if(data == 2) {
                                return "Video";
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'content.title',
                        name: 'content.title',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'episode.name',
                        name: 'episode.name',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'coin',
                        name: 'coin',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "0";
                            }
                        }
                    },
                    {
                        data: 'date',
                        name: 'date'
                    },
                ],
            });
        });
    </script>
@endsection