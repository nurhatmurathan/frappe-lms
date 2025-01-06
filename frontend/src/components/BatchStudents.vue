<template>
	<div class="">
		<div class="flex items-center justify-between w-full pb-4">
			<div class="font-medium text-gray-600">
				{{ __('Статистика') }}
			</div>
		</div>
		<div class="grid grid-cols-3 gap-5 mb-8">
			<div class="flex items-center px-3 py-2 rounded-md shadow">
				<div class="p-2 mr-3 bg-gray-100 rounded-md">
					<User class="w-18 h-18 stroke-1.5 text-gray-700" />
				</div>
				<div class="flex flex-col">
					<span class="mb-1 text-xl font-semibold">
						{{ students.data?.length }}
					</span>
					<span class="text-gray-700">
						{{ __('Студенты') }}
					</span>
				</div>
			</div>

			<div class="flex items-center px-3 py-2 rounded-md shadow">
				<div class="p-2 mr-3 bg-gray-100 rounded-md">
					<BookOpen class="w-18 h-18 stroke-1.5 text-gray-700" />
				</div>
				<div class="flex flex-col">
					<span class="mb-1 text-xl font-semibold">
						{{ batch.courses?.length }}
					</span>
					<span class="text-gray-700">
						{{ __('Курсы') }}
					</span>
				</div>
			</div>

			<div class="flex items-center px-3 py-2 rounded-md shadow">
				<div class="p-2 mr-3 bg-gray-100 rounded-md">
					<ShieldCheck class="w-18 h-18 stroke-1.5 text-gray-700" />
				</div>
				<div class="flex flex-col">
					<span class="mb-1 text-xl font-semibold">
						{{ assessmentCount }}
					</span>
					<span class="text-gray-700">
						{{ __('Оценки') }}
					</span>
				</div>
			</div>
		</div>
		<div class="mb-8">
			<div class="font-medium text-gray-600">
				{{ __('Прогресс') }}
			</div>
			<ApexChart
				v-if="showProgressChart"
				:options="chartOptions"
				:series="chartData"
				type="bar"
				height="350"
			/>
			<div
				class="flex items-center justify-center space-x-4 text-sm text-gray-700"
			>
				<div class="flex items-center space-x-2">
					<div class="w-3 h-3" style="background-color: #0f736b"></div>
					<div>
						{{ __('Курсы') }}
					</div>
				</div>
				<div class="flex items-center space-x-2">
					<div class="w-3 h-3" style="background-color: #0070cc"></div>
					<div>
						{{ __('Оценки') }}
					</div>
				</div>
			</div>
		</div>
	</div>

	<div>
		<div class="flex items-center justify-between mb-4">
			<div class="font-medium text-gray-600">
				{{ __('Студенты') }}
			</div>
			<Button @click="openStudentModal()">
				<template #prefix>
					<Plus class="w-4 h-4" />
				</template>
				{{ __('Добавить') }}
			</Button>
		</div>

		<div v-if="students.data?.length">
			<ListView
				:columns="getStudentColumns()"
				:rows="students.data"
				row-key="name"
				:options="{
					showTooltip: false,
				}"
			>
				<ListHeader
					class="grid items-center p-2 mb-2 space-x-4 bg-gray-100 rounded"
				>
					<ListHeaderItem
						:item="item"
						v-for="item in getStudentColumns()"
						:title="item.label"
					>
						<template #prefix="{ item }">
							<FeatherIcon
								v-if="item.icon"
								:name="item.icon"
								class="h-4 w-4 stroke-1.5"
							/>
						</template>
					</ListHeaderItem>
				</ListHeader>
				<ListRows>
					<ListRow
						:row="row"
						v-for="row in students.data"
						class="cursor-pointer group"
						@click="openStudentProgressModal(row)"
					>
						<template #default="{ column, item }">
							<ListRowItem :item="row[column.key]" :align="column.align">
								<template #prefix>
									<div v-if="column.key == 'full_name'">
										<Avatar
											class="flex items-center"
											:image="row['user_image']"
											:label="item"
											size="sm"
										/>
									</div>
								</template>
								<div
									v-if="column.key == 'progress'"
									class="flex items-center w-full space-x-4"
								>
									<ProgressBar :progress="row[column.key]" size="sm" />
								</div>
								<div
									v-else-if="column.key == 'copy'"
									class="invisible group-hover:visible"
								>
									<Button variant="ghost" @click="copyEmail(row)">
										<template #icon>
											<Clipboard class="h-4 w-4 stroke-1.5" />
										</template>
									</Button>
								</div>
								<div v-else>
									{{ row[column.key] }}
								</div>
							</ListRowItem>
						</template>
					</ListRow>
				</ListRows>
				<ListSelectBanner>
					<template #actions="{ unselectAll, selections }">
						<div class="flex gap-2">
							<Button
								variant="ghost"
								@click="removeStudents(selections, unselectAll)"
							>
								<Trash2 class="h-4 w-4 stroke-1.5" />
							</Button>
						</div>
					</template>
				</ListSelectBanner>
			</ListView>
		</div>
		<div v-else class="text-sm italic text-gray-600">
			{{ __('В этой группе нет студентов.') }}
		</div>
	</div>

	<StudentModal
		:batch="props.batch.name"
		v-model="showStudentModal"
		v-model:reloadStudents="students"
	/>
	<BatchStudentProgress
		:student="selectedStudent"
		v-model="showStudentProgressModal"
	/>
</template>
<script setup>
import BatchStudentProgress from '@/components/Modals/BatchStudentProgress.vue'
import StudentModal from '@/components/Modals/StudentModal.vue'
import ProgressBar from '@/components/ProgressBar.vue'
import { showToast } from '@/utils'
import {
	Avatar,
	Button,
	createResource,
	FeatherIcon,
	ListHeader,
	ListHeaderItem,
	ListRow,
	ListRowItem,
	ListRows,
	ListSelectBanner,
	ListView,
} from 'frappe-ui'
import {
	BookOpen,
	Clipboard,
	Plus,
	ShieldCheck,
	Trash2,
	User,
} from 'lucide-vue-next'
import { ref, watch } from 'vue'
import ApexChart from 'vue3-apexcharts'

const showStudentModal = ref(false)
const showStudentProgressModal = ref(false)
const selectedStudent = ref(null)
const chartData = ref(null)
const chartOptions = ref(null)
const showProgressChart = ref(false)
const assessmentCount = ref(0)

const props = defineProps({
	batch: {
		type: Object,
		default: null,
	},
})

const students = createResource({
	url: 'lms.lms.utils.get_batch_students',
	cache: ['students', props.batch.name],
	params: {
		batch: props.batch?.name,
	},
	auto: true,
	onSuccess(data) {
		chartData.value = getChartData()
		showProgressChart.value = true
	},
})

const getStudentColumns = () => {
	let columns = [
		{
			label: 'Full Name',
			key: 'full_name',
			width: '20rem',
			icon: 'user',
		},
		{
			label: 'Progress',
			key: 'progress',
			width: '10rem',
			icon: 'activity',
		},
		{
			label: 'Last Active',
			key: 'last_active',
			width: '15rem',
			align: 'center',
			icon: 'clock',
		},
		{
			label: '',
			key: 'copy',
		},
	]

	return columns
}

const openStudentModal = () => {
	showStudentModal.value = true
}

const openStudentProgressModal = (row) => {
	showStudentProgressModal.value = true
	selectedStudent.value = row
}

const deleteStudents = createResource({
	url: 'lms.lms.api.delete_documents',
	makeParams(values) {
		return {
			doctype: 'Batch Student',
			documents: values.students,
		}
	},
})

const removeStudents = (selections, unselectAll) => {
	deleteStudents.submit(
		{
			students: Array.from(selections),
		},
		{
			onSuccess(data) {
				students.reload()
				showToast(__('Success'), __('Students deleted successfully'), 'check')
				unselectAll()
			},
		},
	)
}

const getChartData = () => {
	let categories = {}

	Object.keys(students.data?.[0].courses).forEach((course) => {
		categories[course] = {
			value: 0,
			type: 'course',
			label: course,
		}
	})

	Object.keys(students.data?.[0].assessments).forEach((assessment) => {
		categories[assessment] = {
			value: 0,
			type: 'assessment',
			label: assessment,
		}
	})

	students.data.forEach((student) => {
		Object.keys(student.courses).forEach((course) => {
			if (student.courses[course] === 100) {
				categories[course].value += 1
			}
		})

		Object.keys(student.assessments).forEach((assessment) => {
			if (student.assessments[assessment] === 100) {
				categories[assessment].value += 1
			}
		})
	})

	chartOptions.value = getChartOptions(categories)
	return [
		{
			name: __('Completed by Students'),
			data: Object.values(categories).map((item) => item.value),
		},
	]
}

const getChartOptions = (categories) => {
	const courseColor = '#0F736B'
	const assessmentColor = '#0070CC'
	const maxY =
		students.data?.length % 5
			? students.data?.length + (5 - (students.data?.length % 5))
			: students.data?.length

	return {
		chart: {
			type: 'bar',
			height: 50,
			toolbar: {
				show: false,
			},
		},
		plotOptions: {
			bar: {
				distributed: true,
				borderRadius: 0,
				horizontal: true,
				barHeight: '30%',
			},
		},
		colors: Object.values(categories).map((item) =>
			item.type === 'course' ? courseColor : assessmentColor,
		),
		xaxis: {
			categories: Object.values(categories).map((item) => item.label),
			labels: {
				style: {
					fontSize: '10px',
				},
				rotate: 0,
				formatter: function (value) {
					return value.length > 20 ? `${value.substring(0, 20)}...` : value // Trim long labels
				},
			},
		},
		yaxis: {
			max: maxY,
			min: 0,
			stepSize: 10,
			tickAmount: maxY / 5,
		},
	}
}

const copyEmail = (row) => {
	navigator.clipboard.writeText(row.email)
	showToast(__('Success'), __('Email copied to clipboard'), 'check')
}

watch(students, () => {
	if (students.data?.length) {
		assessmentCount.value = Object.keys(students.data?.[0].assessments).length
	}
})
</script>
<style>
.apexcharts-legend {
	display: none !important;
}
</style>
