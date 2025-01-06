<template>
	<div>
		<div class="flex items-center justify-between mb-4">
			<div class="text-lg font-semibold">
				{{ __('Курсы') }}
			</div>
			<Button v-if="canSeeAddButton()" @click="openCourseModal()">
				<template #prefix>
					<Plus class="w-4 h-4" />
				</template>
				{{ __('Добавить') }}
			</Button>
		</div>
		<div v-if="courses.data?.length">
			<ListView
				:columns="getCoursesColumns()"
				:rows="courses.data"
				row-key="batch_course"
				:options="{
					showTooltip: false,
					getRowRoute: (row) => ({
						name: 'CourseDetail',
						params: { courseName: row.name },
					}),
				}"
			>
				<ListHeader
					class="grid items-center p-2 mb-2 space-x-4 bg-gray-100 rounded"
				>
					<ListHeaderItem :item="item" v-for="item in getCoursesColumns()">
						<template #prefix="{ item }">
							<component
								v-if="item.icon"
								:is="item.icon"
								class="h-4 w-4 stroke-1.5 ml-4"
							/>
						</template>
					</ListHeaderItem>
				</ListHeader>
				<ListRows>
					<ListRow :row="row" v-for="row in courses.data">
						<template #default="{ column, item }">
							<ListRowItem :item="row[column.key]" :align="column.align">
								<div>
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
								@click="removeCourses(selections, unselectAll)"
							>
								<Trash2 class="h-4 w-4 stroke-1.5" />
							</Button>
						</div>
					</template>
				</ListSelectBanner>
			</ListView>
		</div>
		<BatchCourseModal
			v-model="showCourseModal"
			:batch="batch"
			v-model:courses="courses"
		/>
	</div>
</template>
<script setup>
import BatchCourseModal from '@/components/Modals/BatchCourseModal.vue'
import { showToast } from '@/utils'
import {
	Button,
	createResource,
	ListHeader,
	ListHeaderItem,
	ListRow,
	ListRowItem,
	ListRows,
	ListSelectBanner,
	ListView,
} from 'frappe-ui'
import { Plus, Trash2 } from 'lucide-vue-next'
import { inject, ref } from 'vue'

const showCourseModal = ref(false)
const user = inject('$user')

const props = defineProps({
	batch: {
		type: String,
		required: true,
	},
})

const courses = createResource({
	url: 'lms.lms.utils.get_batch_courses',
	params: {
		batch: props.batch,
	},
	cache: ['batchCourses', props.batchName],
	auto: true,
})

const openCourseModal = () => {
	showCourseModal.value = true
}

const getCoursesColumns = () => {
	return [
		{
			label: 'Название',
			key: 'title',
			width: 2,
		},
		{
			label: 'Уроки',
			key: 'lessons',
			align: 'right',
		},
		{
			label: 'Записи',
			align: 'right',
			key: 'enrollments',
		},
	]
}

const deleteCourses = createResource({
	url: 'lms.lms.api.delete_documents',
	makeParams(values) {
		return {
			doctype: 'Batch Course',
			documents: values.courses,
		}
	},
})

const removeCourses = (selections, unselectAll) => {
	deleteCourses.submit(
		{
			courses: Array.from(selections),
		},
		{
			onSuccess(data) {
				courses.reload()
				showToast(__('Успех'), __('Курсы успешно удалены'), 'check')
				unselectAll()
			},
		},
	)
}

const canSeeAddButton = () => {
	return user.data?.is_moderator || user.data?.is_evaluator
}
</script>
