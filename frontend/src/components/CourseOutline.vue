<template>
	<div class="text-base">
		<div
			v-if="title && (outline.data?.length || allowEdit)"
			class="grid grid-cols-[70%,30%] mb-4 px-2"
		>
			<div class="text-lg font-semibold leading-5">
				{{ __(title) }}
			</div>
			<Button size="sm" v-if="allowEdit" @click="openChapterModal()">
				{{ __('Добавить главу') }}
			</Button>
			<!-- <span class="font-medium cursor-pointer" @click="expandAllChapters()">
				{{ expandAll ? __("Свернуть все главы") : __("Развернуть все главы") }}
			</span> -->
		</div>
		<div
			:class="{
				'shadow rounded-md py-2 px-2': showOutline && outline.data?.length,
			}"
		>
			<Disclosure
				v-slot="{ open }"
				v-for="(chapter, index) in outline.data"
				:key="chapter.name"
				:defaultOpen="openChapterDetail(chapter.idx)"
			>
				<DisclosureButton ref="" class="flex items-center w-full p-2 group">
					<ChevronRight
						:class="{
							'rotate-90 transform duration-200': open,
							'duration-200': !open,
							hidden: chapter.is_scorm_package,
							open: index == 1,
						}"
						class="w-4 h-4 text-gray-900 stroke-1"
					/>
					<div
						class="ml-2 text-base font-medium leading-5 text-left"
						@click="redirectToChapter(chapter)"
					>
						{{ chapter.title }}
					</div>
					<div class="flex ml-auto space-x-4">
						<Tooltip :text="__('Редактировать главу')" placement="bottom">
							<FilePenLine
								v-if="allowEdit"
								@click.prevent="openChapterModal(chapter)"
								class="invisible w-4 h-4 text-gray-900 group-hover:visible"
							/>
						</Tooltip>
						<Tooltip :text="__('Удалить главу')" placement="bottom">
							<Trash2
								v-if="allowEdit"
								@click.prevent="trashChapter(chapter.name)"
								class="invisible w-4 h-4 text-red-500 group-hover:visible"
							/>
						</Tooltip>
					</div>
				</DisclosureButton>
				<DisclosurePanel v-if="!chapter.is_scorm_package">
					<Draggable
						v-if="!chapter.is_scorm_package"
						:list="chapter.lessons"
						:disabled="!allowEdit"
						item-key="name"
						group="items"
						@end="updateOutline"
						:data-chapter="chapter.name"
					>
						<template #item="{ element: lesson }">
							<div class="py-2 pl-8 pr-4 outline-lesson">
								<router-link
									:to="{
										name: allowEdit ? 'LessonForm' : 'Lesson',
										params: {
											courseName: courseName,
											chapterNumber: lesson.number.split('.')[0],
											lessonNumber: lesson.number.split('.')[1],
										},
									}"
								>
									<div class="flex items-center text-sm leading-5 group">
										<MonitorPlay
											v-if="lesson.icon === 'icon-youtube'"
											class="w-4 h-4 mr-2 text-gray-900 stroke-1"
										/>
										<HelpCircle
											v-else-if="lesson.icon === 'icon-quiz'"
											class="w-4 h-4 mr-2 text-gray-900 stroke-1"
										/>
										<FileText
											v-else-if="lesson.icon === 'icon-list'"
											class="w-4 h-4 mr-2 text-gray-900 stroke-1"
										/>
										{{ lesson.title }}
										<Trash2
											v-if="allowEdit"
											@click.prevent="trashLesson(lesson.name, chapter.name)"
											class="invisible w-4 h-4 ml-auto text-red-500 group-hover:visible"
										/>
										<Check
											v-if="lesson.is_complete"
											class="w-4 h-4 ml-2 text-green-700"
										/>
									</div>
								</router-link>
							</div>
						</template>
					</Draggable>
					<div v-if="allowEdit" class="flex pl-8 mt-2 mb-4">
						<router-link
							v-if="!chapter.is_scorm_package"
							:to="{
								name: 'LessonForm',
								params: {
									courseName: courseName,
									chapterNumber: chapter.idx,
									lessonNumber: chapter.lessons.length + 1,
								},
							}"
						>
							<Button>
								{{ __('Добавить урок') }}
							</Button>
						</router-link>
					</div>
				</DisclosurePanel>
			</Disclosure>
		</div>
	</div>
	<ChapterModal
		v-model="showChapterModal"
		v-model:outline="outline"
		:course="courseName"
		:chapterDetail="getCurrentChapter()"
	/>
</template>
<script setup>
import ChapterModal from '@/components/Modals/ChapterModal.vue'
import { showToast } from '@/utils'
import { Disclosure, DisclosureButton, DisclosurePanel } from '@headlessui/vue'
import { Button, createResource, Tooltip } from 'frappe-ui'
import {
	Check,
	ChevronRight,
	FilePenLine,
	FileText,
	HelpCircle,
	MonitorPlay,
	Trash2,
} from 'lucide-vue-next'
import { getCurrentInstance, inject, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import Draggable from 'vuedraggable'

const route = useRoute()
const router = useRouter()
const user = inject('$user')
const showChapterModal = ref(false)
const currentChapter = ref(null)
const app = getCurrentInstance()
const { $dialog } = app.appContext.config.globalProperties

const props = defineProps({
	courseName: {
		type: String,
		required: true,
	},
	showOutline: {
		type: Boolean,
		default: false,
	},
	title: {
		type: String,
		default: '',
	},
	allowEdit: {
		type: Boolean,
		default: false,
	},
	getProgress: {
		type: Boolean,
		default: false,
	},
})

const outline = createResource({
	url: 'lms.lms.utils.get_course_outline',
	cache: ['course_outline', props.courseName],
	params: {
		course: props.courseName,
		progress: props.getProgress,
	},
	auto: true,
})

const deleteLesson = createResource({
	url: 'lms.lms.api.delete_lesson',
	makeParams(values) {
		return {
			lesson: values.lesson,
			chapter: values.chapter,
		}
	},
	onSuccess() {
		outline.reload()
		showToast('Успех', 'Урок успешно удален', 'check')
	},
})

const updateLessonIndex = createResource({
	url: 'lms.lms.api.update_lesson_index',
	makeParams(values) {
		return {
			lesson: values.lesson,
			sourceChapter: values.sourceChapter,
			targetChapter: values.targetChapter,
			idx: values.idx,
		}
	},
	onSuccess() {
		showToast('Успех', 'Урок успешно перемещен', 'check')
	},
})

const trashLesson = (lessonName, chapterName) => {
	$dialog({
		title: __('Удалить этот урок?'),
		message: __(
			'Удаление этого урока навсегда удалит его из курса. Это действие нельзя отменить. Вы уверены, что хотите продолжить?',
		),
		actions: [
			{
				label: __('Удалить'),
				theme: 'red',
				variant: 'solid',
				onClick(close) {
					deleteLesson.submit({
						lesson: lessonName,
						chapter: chapterName,
					})
					close()
				},
			},
		],
	})
}

const openChapterDetail = (index) => {
	return index == route.params.chapterNumber || index == 1
}

const openChapterModal = (chapter = null) => {
	currentChapter.value = chapter
	showChapterModal.value = true
}

const getCurrentChapter = () => {
	return currentChapter.value
}

const updateOutline = (e) => {
	updateLessonIndex.submit({
		lesson: e.item.__draggable_context.element.name,
		sourceChapter: e.from.dataset.chapter,
		targetChapter: e.to.dataset.chapter,
		idx: e.newIndex,
	})
}

const deleteChapter = createResource({
	url: 'lms.lms.api.delete_chapter',
	makeParams(values) {
		return {
			chapter: values.chapter,
		}
	},
	onSuccess() {
		outline.reload()
		showToast('Успех', 'Глава успешно удалена', 'check')
	},
})

const trashChapter = (chapterName) => {
	$dialog({
		title: __('Удалить эту главу?'),
		message: __(
			'Удаление этой главы также удалит все ее уроки и навсегда удалит ее из курса. Это действие нельзя отменить. Вы уверены, что хотите продолжить?',
		),
		actions: [
			{
				label: __('Удалить'),
				theme: 'red',
				variant: 'solid',
				onClick(close) {
					deleteChapter.submit({ chapter: chapterName })
					close()
				},
			},
		],
	})
}

const redirectToChapter = (chapter) => {
	if (!chapter.is_scorm_package) return
	event.preventDefault()
	if (props.allowEdit) return
	if (!user.data) {
		showToast(
			__('Вы не зачислены'),
			__('Пожалуйста, запишитесь на этот курс, чтобы просмотреть этот урок'),
			'alert-circle',
		)
		return
	}

	router.push({
		name: 'SCORMChapter',
		params: {
			courseName: props.courseName,
			chapterName: chapter.name,
		},
	})
}
</script>
<style>
.outline-lesson:has(.router-link-active) {
	background-color: theme('colors.gray.100');
}
</style>
