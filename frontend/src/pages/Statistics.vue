<template>
	<div class="">
		<header
			class="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
		>
			<Breadcrumbs class="h-7" :items="breadcrumbs" />
		</header>
		<div v-if="chartDetails.data" class="p-5">
			<div class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-5">
				<div class="flex items-center px-3 py-2 rounded-md shadow">
					<div class="p-2 mr-3 bg-gray-100 rounded-md">
						<BookOpen class="w-18 h-18 stroke-1.5 text-gray-700" />
					</div>
					<div>
						<div class="mb-1 text-xl font-semibold">
							{{ formatNumber(chartDetails.data.courses) }}
						</div>
						<div class="text-gray-700">
							{{ __('Курсы') }}
						</div>
					</div>
				</div>
				<div class="flex items-center px-3 py-2 rounded-md shadow">
					<div class="p-2 mr-3 bg-gray-100 rounded-md">
						<LogIn class="w-18 h-18 stroke-1.5 text-gray-700" />
					</div>
					<div>
						<div class="mb-1 text-xl font-semibold">
							{{ formatNumber(chartDetails.data.users) }}
						</div>
						<div class="text-gray-700">
							{{ __('Регистрации') }}
						</div>
					</div>
				</div>
				<div class="flex items-center px-3 py-2 rounded-md shadow">
					<div class="p-2 mr-3 bg-gray-100 rounded-md">
						<BookOpenCheck class="w-18 h-18 stroke-1.5 text-gray-700" />
					</div>
					<div>
						<div class="mb-1 text-xl font-semibold">
							{{ formatNumber(chartDetails.data.enrollments) }}
						</div>
						<div class="text-gray-700">
							{{ __('Зачисления') }}
						</div>
					</div>
				</div>
				<div class="flex items-center px-3 py-2 rounded-md shadow">
					<div class="p-2 mr-3 bg-gray-100 rounded-md">
						<FileCheck class="w-18 h-18 stroke-1.5 text-gray-700" />
					</div>
					<div>
						<div class="mb-1 text-xl font-semibold">
							{{ formatNumber(chartDetails.data.completions) }}
						</div>
						<div class="text-gray-700">
							{{ __('Завершения') }}
						</div>
					</div>
				</div>
				<div class="flex items-center px-3 py-2 rounded-md shadow">
					<div class="p-2 mr-3 bg-gray-100 rounded-md">
						<FileCheck2 class="w-18 h-18 stroke-1.5 text-gray-700" />
					</div>
					<div>
						<div class="mb-1 text-xl font-semibold">
							{{ formatNumber(chartDetails.data.lesson_completions) }}
						</div>
						<div class="text-gray-700">
							{{ __('Уроки завершены') }}
						</div>
					</div>
				</div>
			</div>
			<div class="grid grid-cols-1 gap-4 mt-4 lg:grid-cols-2">
				<div class="p-5 rounded-md shadow min-h-72">
					<Line
						v-if="signupsChart.data"
						:data="signupsChart.data"
						:options="signupChartOptions()"
					/>
				</div>
				<div class="p-5 rounded-md shadow min-h-72">
					<Line
						v-if="enrollmentChart.data"
						:data="enrollmentChart.data"
						:options="enrollmentChartOptions()"
					/>
				</div>
				<div class="p-5 rounded-md shadow">
					<Line
						v-if="lessonCompletion.data"
						:data="lessonCompletion.data"
						:options="lessonChartOptions()"
					/>
				</div>
				<div class="p-5 rounded-md shadow">
					<Pie
						v-if="courseCompletion.data"
						:data="courseCompletion.data"
						:options="courseChartOptions()"
					/>
				</div>
			</div>
		</div>
	</div>
</template>
<script setup>
import { formatNumber, updateDocumentTitle } from '@/utils'
import {
	ArcElement,
	CategoryScale,
	Chart as ChartJS,
	Filler,
	Legend,
	LinearScale,
	LineElement,
	PointElement,
	Title,
	Tooltip,
} from 'chart.js'
import { Breadcrumbs, createResource } from 'frappe-ui'
import {
	BookOpen,
	BookOpenCheck,
	FileCheck,
	FileCheck2,
	LogIn,
} from 'lucide-vue-next'
import { computed, inject } from 'vue'
import { Line, Pie } from 'vue-chartjs'

ChartJS.register(
	Title,
	Tooltip,
	Legend,
	LineElement,
	CategoryScale,
	LinearScale,
	PointElement,
	ArcElement,
	Filler,
)

const dayjs = inject('$dayjs')

const breadcrumbs = computed(() => {
	return [
		{
			label: 'Статистика',
			route: {
				name: 'Statistics',
			},
		},
	]
})

const chartDetails = createResource({
	url: 'lms.lms.api.get_chart_details',
	cache: ['statistics'],
	auto: true,
})

const signupsChart = createResource({
	url: 'lms.lms.utils.get_chart_data',
	cache: ['signups'],
	params: {
		chart_name: 'New Signups',
	},
	auto: true,
})

const enrollmentChart = createResource({
	url: 'lms.lms.utils.get_chart_data',
	cache: ['enrollments'],
	params: {
		chart_name: 'Course Enrollments',
	},
	auto: true,
})

const lessonCompletion = createResource({
	url: 'lms.lms.utils.get_chart_data',
	cache: ['lessonCompletion'],
	params: {
		chart_name: 'Lesson Completion',
	},
	auto: true,
})

const courseCompletion = createResource({
	url: 'lms.lms.utils.get_course_completion_data',
	auto: true,
	cache: ['courseCompletion'],
})

const signupChartOptions = () => {
	let options = chartOptions(false)
	options.plugins.title.text = 'Signups'
	options.borderColor = '#4563f0'
	options.backgroundColor = (ctx) => {
		const canvas = ctx.chart.ctx
		const gradient = canvas.createLinearGradient(0, 0, 0, 160)
		gradient.addColorStop(0, '#4563f0')
		gradient.addColorStop(0.5, '#e8ecfe')
		gradient.addColorStop(1, '#f6f7ff')

		return gradient
	}
	return options
}

const enrollmentChartOptions = () => {
	let options = chartOptions(false)
	options.plugins.title.text = 'Enrollments'
	options.borderColor = '#4563f0'
	options.backgroundColor = (ctx) => {
		const canvas = ctx.chart.ctx
		const gradient = canvas.createLinearGradient(0, 0, 0, 160)
		gradient.addColorStop(0, '#4563f0')
		gradient.addColorStop(0.5, '#e8ecfe')
		gradient.addColorStop(1, '#f6f7ff')

		return gradient
	}
	return options
}

const lessonChartOptions = () => {
	let options = chartOptions(false)
	options.plugins.title.text = 'Milestones'
	options.borderColor = '#4563f0'
	options.backgroundColor = (ctx) => {
		const canvas = ctx.chart.ctx
		const gradient = canvas.createLinearGradient(0, 0, 0, 160)
		gradient.addColorStop(0, '#B6DEC5')
		gradient.addColorStop(0.5, '#e8ecfe')
		gradient.addColorStop(1, '#f6f7ff')

		return gradient
	}
	return options
}

const courseChartOptions = () => {
	let options = chartOptions(true)
	options.plugins.title.text = 'Completions'
	options.backgroundColor = ['#4563f0', '#f683ae']
	return options
}

const chartOptions = (isPie) => {
	return {
		responsive: true,
		maintainAspectRatio: false,
		fill: true,
		borderWidth: 2,
		pointRadius: 2,
		pointStyle: 'cross',
		ticks: {
			autoSkip: true,
			maxTicksLimit: 5,
		},
		plugins: {
			legend: {
				display: isPie ? true : false,
			},
			title: {
				display: true,
				align: 'start',
				font: {
					size: 14,
					weight: '500',
				},
				color: '#171717',
				padding: {
					bottom: 20,
				},
			},
			tooltip: {
				backgroundColor: '#000',
			},
		},
		scales: {
			x: {
				display: isPie ? false : true,
				grid: {
					display: false,
				},
				border: {
					display: isPie ? false : true,
				},
			},
			y: {
				beginAtZero: true,
				display: isPie ? false : true,
				grid: {
					display: false,
				},
				border: {
					display: isPie ? false : true,
				},
			},
		},
	}
}

const pageMeta = computed(() => {
	return {
		title: 'Statistics',
		description: 'Statistics of the platform',
	}
})

updateDocumentTitle(pageMeta)
</script>
